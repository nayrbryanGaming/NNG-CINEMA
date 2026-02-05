import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String movieId;
  final String cinemaId;
  final String hallId;
  final DateTime startAt;
  final DateTime endAt;
  final double price;

  ScheduleModel({required this.id, required this.movieId, required this.cinemaId, required this.hallId, required this.startAt, required this.endAt, required this.price});

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'cinemaId': cinemaId,
        'hallId': hallId,
        'startAt': Timestamp.fromDate(startAt),
        'endAt': Timestamp.fromDate(endAt),
        'price': price,
      };

  factory ScheduleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScheduleModel(
      id: doc.id,
      movieId: data['movieId'] ?? '',
      cinemaId: data['cinemaId'] ?? '',
      hallId: data['hallId'] ?? '',
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endAt: (data['endAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}

