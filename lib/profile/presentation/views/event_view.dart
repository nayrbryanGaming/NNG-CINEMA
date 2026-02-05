import 'package:flutter/material.dart';
import 'package:movies_app/core/presentation/components/shimmer_image.dart';
import 'package:movies_app/core/presentation/utils/color_utils.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock events data
    final List<Map<String, dynamic>> events = [
      {
        'title': 'MISSION TO KOREA',
        'type': 'STAMP COLLECTION',
        'endDate': 'END 11/12/2025',
        'banner': 'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=800',
        'description': 'Win a trip to Korea for 3 person',
        'color': const Color(0xFF8BC34A),
      },
      {
        'title': 'MOVIE MARATHON WEEKEND',
        'type': 'SPECIAL EVENT',
        'endDate': 'END 30/11/2025',
        'banner': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        'description': 'Watch 3 movies get 1 free',
        'color': const Color(0xFFFF5722),
      },
      {
        'title': 'STUDENT DISCOUNT',
        'type': 'ONGOING',
        'endDate': 'PERMANENT',
        'banner': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
        'description': 'Get 25% off with student ID',
        'color': const Color(0xFF2196F3),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Event Seru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(context, event);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: withOpacityColor(event['color'] as Color, 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                ShimmerImage(
                  imageUrl: event['banner'],
                  width: double.infinity,
                  height: 200,
                ),
                // Gradient overlay
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        withOpacityColor(Colors.black, 0.7),
                      ],
                    ),
                  ),
                ),
                // Event type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['type'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // End date badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event['endDate'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Event info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['description'],
                  style: TextStyle(
                    color: withOpacityColor(Colors.white, 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // View detail button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showEventDetail(context, event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event['color'],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'VIEW DETAIL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetail(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: withOpacityColor(Colors.white, 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Event banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ShimmerImage(
                imageUrl: event['banner'],
                width: MediaQuery.of(context).size.width - 32,
                height: 180,
              ),
            ),
            const SizedBox(height: 20),
            // Event details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: event['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event['type'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          color: withOpacityColor(Colors.white, 0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event['endDate'],
                          style: TextStyle(
                            color: withOpacityColor(Colors.white, 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About This Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event['description'],
                      style: TextStyle(
                        color: withOpacityColor(Colors.white, 0.7),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Valid for all NNG Cinema locations\n'
                      '• Cannot be combined with other promotions\n'
                      '• Terms and conditions apply\n'
                      '• NNG Cinema reserves the right to change T&C',
                      style: TextStyle(
                        color: withOpacityColor(Colors.white, 0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

