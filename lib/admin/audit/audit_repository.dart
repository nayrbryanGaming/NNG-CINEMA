import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_model.dart';

class AuditRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('admin_audit');

  Future<void> logAdminAction({required String adminId, required String action, required String target, Map<String, dynamic>? before, Map<String, dynamic>? after}) async {
    await _col.add({
      'adminId': adminId,
      'action': action,
      'entityType': '',
      'entityId': target,
      'before': before,
      'after': after,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<AuditModel>> list({int limit = 100}) async {
    final snap = await _col.orderBy('timestamp', descending: true).limit(limit).get();
    return snap.docs.map((d) => AuditModel.fromSnapshot(d)).toList();
  }
}

