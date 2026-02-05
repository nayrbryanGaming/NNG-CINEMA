import 'package:cloud_firestore/cloud_firestore.dart';

class CinemaModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final List<Map<String, dynamic>> halls;
  final DateTime createdAt;
  final DateTime updatedAt;

  CinemaModel({required this.id, required this.name, required this.city, required this.address, required this.halls, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'address': address,
        'halls': halls,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory CinemaModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CinemaModel(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      address: data['address'] ?? '',
      halls: List<Map<String, dynamic>>.from(data['halls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

