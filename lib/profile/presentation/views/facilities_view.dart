import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class FacilitiesView extends StatefulWidget {
  const FacilitiesView({super.key});

  @override
  State<FacilitiesView> createState() => _FacilitiesViewState();
}

class _FacilitiesViewState extends State<FacilitiesView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed(AppRoutes.menuRoute),
        ),
        title: const Text('NNG Cinema Special Feature'),
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Auditoriums', 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton('Sports', 1),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0 ? _buildAuditoriumsTab() : _buildSportsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedTab = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.grey[900],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAuditoriumsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFacilityCard(
          'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?w=800&fit=crop',
          'sky',
          'Big screen, in open sky',
          'Experience cinema under the stars with our open-air screen technology.',
        ),
        const SizedBox(height: 16),
        _buildFacilityCard(
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&fit=crop',
          'SCREEN X',
          "One of the World's LARGEST with Dolby Atmos",
          '270-degree panoramic viewing experience with the biggest screen.',
        ),
        const SizedBox(height: 16),
        _buildFacilityCard(
          'https://images.unsplash.com/photo-1513106580091-1d82408b8cd6?w=800&fit=crop',
          'GOLD CLASS',
          'PREMIUM & COZY - Best comfort & convenience movie watching',
          'Luxury recliner seats with personal service and premium amenities.',
        ),
        const SizedBox(height: 16),
        _buildFacilityCard(
          'https://images.unsplash.com/photo-1574267432644-f610f65fb1c0?w=800&fit=crop',
          'velvet',
          'The first Sofa Bed concept in Indonesia',
          'Lay back and relax on our exclusive sofa bed seating.',
        ),
      ],
    );
  }

  Widget _buildSportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSportsCard(
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800&fit=crop',
          'Football Live Screening',
          'Watch major football leagues and tournaments on the big screen',
        ),
        const SizedBox(height: 16),
        _buildSportsCard(
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&fit=crop',
          'NBA & Basketball',
          'Catch every dunk and three-pointer in stunning quality',
        ),
        const SizedBox(height: 16),
        _buildSportsCard(
          'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800&fit=crop',
          'UFC & Boxing',
          'Feel the intensity of every punch and knockout',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.sports, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check our Sports Hall section for the latest schedules',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Sports Hall section...'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                ),
                child: const Text('View Sports Hall'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityCard(String imageUrl, String title, String subtitle, String description) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title - Learn more about this facility'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.purple,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.theaters, size: 64, color: Colors.white38),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSportsCard(String imageUrl, String title, String description) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title - View upcoming matches'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.sports, size: 64, color: Colors.white38),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
