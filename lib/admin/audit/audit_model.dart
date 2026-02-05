import 'package:cloud_firestore/cloud_firestore.dart';

class AuditModel {
  final String id;
  final String adminId;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final DateTime timestamp;

  AuditModel({required this.id, required this.adminId, required this.action, required this.entityType, required this.entityId, this.before, this.after, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'adminId': adminId,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'before': before,
        'after': after,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory AuditModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuditModel(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      action: data['action'] ?? '',
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      before: data['before'] as Map<String, dynamic>?,
      after: data['after'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

