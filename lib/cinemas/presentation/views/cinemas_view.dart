// Restore: clean, working CinemasView with search, filtering, and network thumbnails
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_bloc.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_event.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_state.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import '../../data/cinema_images.dart' as cinema_images;
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';

class CinemasView extends StatefulWidget {
  const CinemasView({Key? key}) : super(key: key);

  @override
  State<CinemasView> createState() => _CinemasViewState();
}

class _CinemasViewState extends State<CinemasView> {
  final TextEditingController _searchController = TextEditingController();
  List<Cinema> _filteredCinemas = [];
  List<Cinema> _allCinemas = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCinemas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCinemas = _allCinemas;
      } else {
        _filteredCinemas = _allCinemas
            .where((cinema) =>
                cinema.name.toLowerCase().contains(query.toLowerCase()) ||
                cinema.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<CinemasBloc>();
        Future.microtask(() => bloc.add(GetCinemasEvent()));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'Bioskop',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              onPressed: () => context.pushNamed(AppRoutes.myTicketsRoute),
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
              tooltip: 'My Tickets',
            )
          ],
        ),
        body: BlocBuilder<CinemasBloc, CinemasState>(
          builder: (context, state) {
            if (state is CinemasLoading) return const LoadingIndicator();
            if (state is CinemasLoaded) {
              // initialize lists once
              if (_allCinemas.isEmpty) {
                _allCinemas = state.cinemas;
                _filteredCinemas = state.cinemas;
              }

              return Column(
                children: [
                  // Search bar
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3C3C3C), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterCinemas,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari nama teater atau lokasi...',
                        hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color.fromRGBO(255, 255, 255, 0.6)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Color.fromRGBO(255, 255, 255, 0.6)),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterCinemas('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  // Cinema count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '${_filteredCinemas.length} Bioskop Tersedia',
                          style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: _filteredCinemas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.search_off_rounded, size: 64, color: Color.fromRGBO(255, 255, 255, 0.3)),
                                SizedBox(height: 16),
                                Text('Tidak ada bioskop ditemukan', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 16)),
                                SizedBox(height: 8),
                                Text('Coba kata kunci lain', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4), fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100, top: 8),
                            itemCount: _filteredCinemas.length,
                            itemBuilder: (context, index) => _buildCinemaCard(context, _filteredCinemas[index]),
                          ),
                  ),
                ],
              );
            }

            if (state is CinemasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Gagal memuat data', style: const TextStyle(color: Color.fromRGBO(255,255,255,0.9), fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(state.message, style: const TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CinemasBloc>().add(GetCinemasEvent()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Welcome to Cinemas', style: TextStyle(color: Colors.white)));
          },
        ),
      ),
    );
  }

  Widget _buildCinemaCard(BuildContext context, Cinema cinema) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.pushNamed(AppRoutes.cinemaDetailsRoute, extra: cinema),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Cinema image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF3C3C3C), width: 1), color: const Color(0xFF2C2C2C)),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: cinema_images.getCinemaImageUrl(cinema),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFF2C2C2C), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (context, url, error) => _defaultCinemaPlaceholder(),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cinema.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.location_on_rounded, color: Color.fromRGBO(255,255,255,0.6), size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(cinema.location, style: const TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 13, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Color.fromRGBO(255,255,255,0.4), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultCinemaPlaceholder() {
    return Container(
      color: const Color(0xFF2C2C2C),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.theaters_rounded, color: Color.fromRGBO(255,255,255,0.7), size: 36),
          SizedBox(height: 4),
          Text('CINEMA', style: TextStyle(color: Color.fromRGBO(255,255,255,0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
