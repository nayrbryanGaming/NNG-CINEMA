import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final List<String> roles;

  UserModel({required this.id, required this.email, this.displayName, required this.roles});

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'roles': roles,
      };

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] as String?,
      roles: List<String>.from(data['roles'] ?? []),
    );
  }
}

