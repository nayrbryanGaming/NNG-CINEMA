import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/presentation/components/vertical_listview.dart';
import 'package:movies_app/core/presentation/components/vertical_listview_card.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_bloc.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_event.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_state.dart';

class RecommendationView extends StatelessWidget {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecommendationBloc>(),
      // Use a Builder to get the correct context for the Bloc
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rekomendasi & Pencarian'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (query) {
                    context.read<RecommendationBloc>().add(SearchEvent(query));
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari film, acara TV, atau genre...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 24),
                // Weather Recommendation Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<RecommendationBloc>().add(GetWeatherRecommendationEvent());
                  },
                  icon: const Icon(Icons.wb_sunny_rounded),
                  label: const Text('Rekomendasi Film Berdasarkan Cuaca'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 40),
                // Results Area
                Expanded(
                  child: BlocBuilder<RecommendationBloc, RecommendationState>(
                    builder: (context, state) {
                      if (state is RecommendationLoading) {
                        return const LoadingIndicator();
                      }
                      if (state is RecommendationLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(state.title, style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Expanded(
                              child: VerticalListView(
                                itemCount: state.movies.length,
                                itemBuilder: (context, index) {
                                  return VerticalListViewCard(media: state.movies[index]);
                                },
                                addEvent: () {}, // No pagination needed here
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is RecommendationError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(
                        child: Text('Hasil akan ditampilkan di sini.', style: TextStyle(color: Colors.grey)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
