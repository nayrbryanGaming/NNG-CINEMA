import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title;
  final String synopsis;
  final List<String> genres;
  final int durationMinutes;
  final double rating;
  final String? trailerUrl;
  final String? posterUrl;
  final String status; // draft / published
  final DateTime createdAt;
  final DateTime updatedAt;

  MovieModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.genres,
    required this.durationMinutes,
    required this.rating,
    this.trailerUrl,
    this.posterUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'synopsis': synopsis,
        'genres': genres,
        'durationMinutes': durationMinutes,
        'rating': rating,
        'trailerUrl': trailerUrl,
        'posterUrl': posterUrl,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory MovieModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MovieModel(
      id: doc.id,
      title: data['title'] ?? '',
      synopsis: data['synopsis'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      durationMinutes: (data['durationMinutes'] ?? 0) as int,
      rating: (data['rating'] ?? 0).toDouble(),
      trailerUrl: data['trailerUrl'] as String?,
      posterUrl: data['posterUrl'] as String?,
      status: data['status'] ?? 'draft',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

