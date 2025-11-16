import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_bloc.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_event.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_state.dart';
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';

class CinemasView extends StatelessWidget {
  const CinemasView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CinemasBloc>()..add(GetCinemasEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bioskop'),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.myTicketsRoute);
              },
              icon: const Icon(Icons.receipt_long_rounded),
              tooltip: 'My Tickets',
            )
          ],
        ),
        body: BlocBuilder<CinemasBloc, CinemasState>(
          builder: (context, state) {
            if (state is CinemasLoading) {
              return const LoadingIndicator();
            } else if (state is CinemasLoaded) {
              return ListView.builder(
                itemCount: state.cinemas.length,
                itemBuilder: (context, index) {
                  final cinema = state.cinemas[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(cinema.name),
                      subtitle: Text(cinema.location),
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.cinemaDetailsRoute,
                          extra: cinema,
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is CinemasError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const Center(
                child: Text('Welcome to Cinemas'),
              );
            }
          },
        ),
      ),
    );
  }
}
