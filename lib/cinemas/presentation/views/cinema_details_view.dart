import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/core/presentation/components/image_with_shimmer.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class CinemaDetailsView extends StatelessWidget {
  final Cinema cinema;

  const CinemaDetailsView({
    super.key,
    required this.cinema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cinema.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: cinema.movieShowtimes.length,
        itemBuilder: (context, index) {
          final movieShowtime = cinema.movieShowtimes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: ImageWithShimmer(
                      imageUrl: movieShowtime.posterUrl,
                      width: 100,
                      height: 150,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movieShowtime.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: movieShowtime.showtimes.map((time) {
                            return ElevatedButton(
                              onPressed: () {
                                context.pushNamed(
                                  AppRoutes.seatSelectionRoute,
                                  extra: {
                                    'cinema': cinema,
                                    'movieShowtime': movieShowtime,
                                    'selectedTime': time,
                                  },
                                );
                              },
                              child: Text(time),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
