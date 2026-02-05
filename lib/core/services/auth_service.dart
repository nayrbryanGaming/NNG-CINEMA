import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Custom exception for auth-related errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  @override
  String toString() => 'AuthException[$code]: $message';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Update last login timestamp
      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown error');
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Create user doc in Firestore
      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName ?? '',
          'photoUrl': '',
          'uid': user.uid,
          'username': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown error');
    }
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      // Create anonymous user doc in Firestore
      final user = credential.user;
      if (user != null) {
        // Generate unique username: @user + 20 random digits
        final uniqueId = _generateUniqueId(20);
        final username = '@user$uniqueId';

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'name': 'Anonymous User',
          'photoUrl': '', // Empty = will use default placeholder
          'isAnonymous': true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown error');
    }
  }

  /// Generate unique ID with specified length of random digits
  String _generateUniqueId(int length) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString();
    final buffer = StringBuffer();

    // Add timestamp-based digits
    for (int i = 0; i < random.length && buffer.length < length; i++) {
      buffer.write(random[i]);
    }

    // Fill remaining with hash-based random digits
    var hash = timestamp;
    while (buffer.length < length) {
      hash = (hash * 1103515245 + 12345) & 0x7fffffff;
      buffer.write(hash % 10);
    }

    return buffer.toString().substring(0, length);
  }

  /// Check at runtime whether assets/google-services.json contains a valid Android oauth_client
  Future<bool> _hasValidAndroidOauthClient() async {
    try {
      final raw = await rootBundle.loadString('assets/google-services.json');
      final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
      final clients = data['client'] as List?;
      if (clients == null || clients.isEmpty) return false;
      final client = clients.first as Map<String, dynamic>;
      final oauth = client['oauth_client'] as List?;
      if (oauth == null || oauth.isEmpty) return false;
      final android = oauth.where((o) => (o as Map)['client_type'] == 1).toList();
      if (android.isEmpty) return false;
      for (final o in android) {
        final m = o as Map<String, dynamic>;
        final cid = (m['client_id'] ?? '') as String;
        final ai = m['android_info'] as Map<String, dynamic>?;
        final chash = ai == null ? null : ai['certificate_hash'] as String?;
        if (cid.trim().isEmpty) return false;
        if (cid.contains('REPLACE_WITH')) return false;
        if (chash == null || chash.split(':').length < 4) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Jalankan Google Sign-In
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user aborted

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      // Simpan data user ke Firestore (WAJIB: data asli, bukan dummy)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL ?? '',
        'uid': user.uid,
        'username': user.email, // default, bisa diedit user nanti
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return userCredential;
  }

  /// If the current user is anonymous, link with email/password to upgrade account
  Future<UserCredential> linkAnonymousWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(code: 'no-current-user', message: 'No current user to link');
    }
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return await user.linkWithCredential(credential);
  }

  /// If current user is anonymous, link with Google account
  Future<UserCredential?> linkAnonymousWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException(code: 'no-current-user', message: 'No current user to link');
    if (!user.isAnonymous) throw AuthException(code: 'not-anonymous', message: 'Current user is not anonymous');

    if (!await _hasValidAndroidOauthClient()) {
      // cannot link via Google because config is missing
      throw AuthException(code: 'google-config-missing', message: 'Google OAuth not configured for Android in google-services.json');
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // aborted
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await user.linkWithCredential(credential);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // ignore errors
    }
  }

  User? get currentUser => _auth.currentUser;

  /// Update username for current user in Firestore
  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(code: 'no-current-user', message: 'No current user to update');
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': username,
    }, SetOptions(merge: true));
  }

  /// Upload and update profile photo to Firebase Storage, then update Firestore
  Future<void> uploadAndSaveProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(code: 'no-current-user', message: 'No current user to update photo');
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return; // user cancelled
    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'photoUrl': downloadUrl,
    }, SetOptions(merge: true));
  }

  /// Ambil stream notifikasi promo/diskon nyata dari Firestore
  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return empty stream jika belum login
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  /// Catat notifikasi promo/diskon nyata ke Firestore
  Future<void> logPromoNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Validasi: hanya catat jika title dan body bukan placeholder
    if (title.trim().toLowerCase().contains('placeholder') ||
        body.trim().toLowerCase().contains('placeholder')) {
      return;
    }
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items');
    await notifRef.add({
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
