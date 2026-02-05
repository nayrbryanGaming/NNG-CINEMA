import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import 'package:movies_app/admin/audit/audit_repository.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';

class UserRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('users');
  final AuditRepository _audit = AuditRepository();

  Future<List<UserModel>> list({int limit = 50}) async {
    final snap = await _col.limit(limit).get();
    return snap.docs.map((d) => UserModel.fromSnapshot(d)).toList();
  }

  Future<void> setRole(String userId, List<String> roles) async {
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final currentUid = auth?.currentUser?.uid;
    final beforeDoc = await _col.doc(userId).get();
    final before = beforeDoc.data() as Map<String, dynamic>?;
    await _col.doc(userId).update({'roles': roles, 'updatedAt': Timestamp.fromDate(DateTime.now())});
    await _audit.logAdminAction(adminId: currentUid ?? 'unknown', action: 'SET_USER_ROLES', target: userId, before: before, after: {'roles': roles});
  }
}
