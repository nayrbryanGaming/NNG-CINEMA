import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie_model.dart';
import 'package:movies_app/admin/audit/audit_repository.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';

class MovieRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('movies');
  final AuditRepository _audit = AuditRepository();

  Future<List<MovieModel>> list({int limit = 20, DocumentSnapshot? startAfter}) async {
    Query q = _col.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map((d) => MovieModel.fromSnapshot(d)).toList();
  }

  Stream<List<MovieModel>> streamAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => MovieModel.fromSnapshot(d)).toList(),
        );
  }

  Future<MovieModel> getById(String id) async {
    final doc = await _col.doc(id).get();
    return MovieModel.fromSnapshot(doc);
  }

  Future<String> create(MovieModel m) async {
    final now = DateTime.now();
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final currentUid = auth?.currentUser?.uid;
    final ref = await _col.add({
      ...m.toJson(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    // Audit log
    try {
      await _audit.logAdminAction(adminId: currentUid ?? 'unknown', action: 'CREATE_MOVIE', target: ref.id, before: null, after: m.toJson());
    } catch (_) {}
    return ref.id;
  }

  Future<void> update(MovieModel m) async {
    final now = DateTime.now();
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final currentUid = auth?.currentUser?.uid;
    // read before
    try {
      final beforeDoc = await _col.doc(m.id).get();
      final before = beforeDoc.data() as Map<String, dynamic>?;
      await _col.doc(m.id).update({
        ...m.toJson(),
        'updatedAt': Timestamp.fromDate(now),
      });
      await _audit.logAdminAction(adminId: currentUid ?? 'unknown', action: 'UPDATE_MOVIE', target: m.id, before: before, after: m.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final currentUid = auth?.currentUser?.uid;
    try {
      final beforeDoc = await _col.doc(id).get();
      final before = beforeDoc.data() as Map<String, dynamic>?;
      await _col.doc(id).delete();
      await _audit.logAdminAction(adminId: currentUid ?? 'unknown', action: 'DELETE_MOVIE', target: id, before: before, after: null);
    } catch (e) {
      rethrow;
    }
  }
}
