import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart';
import 'package:movies_app/admin/audit/audit_repository.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';

class OrderRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('orders');
  final AuditRepository _audit = AuditRepository();

  Future<List<OrderModel>> list({int limit = 50}) async {
    final snap = await _col.orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => OrderModel.fromSnapshot(d)).toList();
  }

  Stream<List<OrderModel>> streamRecent({int limit = 50}) =>
      _col.orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => OrderModel.fromSnapshot(d)).toList());

  Future<void> updateStatus(String id, String status) async {
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final currentUid = auth?.currentUser?.uid;
    try {
      final beforeDoc = await _col.doc(id).get();
      final before = beforeDoc.data() as Map<String, dynamic>?;
      await _col.doc(id).update({'status': status, 'updatedAt': Timestamp.fromDate(DateTime.now())});
      await _audit.logAdminAction(adminId: currentUid ?? 'unknown', action: 'UPDATE_ORDER_STATUS', target: id, before: before, after: {'status': status});
    } catch (e) {
      rethrow;
    }
  }
}
