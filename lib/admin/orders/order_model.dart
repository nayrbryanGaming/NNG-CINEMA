import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String scheduleId;
  final List<String> seats;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  OrderModel({required this.id, required this.userId, required this.scheduleId, required this.seats, required this.totalPrice, required this.status, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'scheduleId': scheduleId,
        'seats': seats,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      scheduleId: data['scheduleId'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

