import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _promoCategories = ['All', 'Concession', 'Movies', 'Merchandise'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: const Text('Promotions & News'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'PROMOTIONS'),
            Tab(text: 'NEWS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPromotionsTab(),
          _buildNewsTab(),
        ],
      ),
    );
  }

  Widget _buildPromotionsTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _promoCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == _promoCategories.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: const Icon(Icons.tune, size: 18),
                    backgroundColor: Colors.grey[900],
                    side: BorderSide(color: Colors.grey[700]!),
                    onSelected: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filter options coming soon'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                );
              }
              final isFirst = index == 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_promoCategories[index]),
                  selected: isFirst,
                  selectedColor: Colors.red,
                  backgroundColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: isFirst ? Colors.white : Colors.grey,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Showing ${_promoCategories[index]} promotions'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Promo List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPromoCard(
                'https://images.unsplash.com/photo-1595769816263-9b910be24d5f?w=800&fit=crop',
                '<ZOOTOPIA 2> MERCHANDISE COMBO',
                '3 DAYS AGO',
              ),
              const SizedBox(height: 16),
              _buildPromoCard(
                'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800&fit=crop',
                'NONTON ROMBONGAN, JAJAN MAKIN CUAN DI CGV!',
                'A DAY AGO',
              ),
              const SizedBox(height: 16),
              _buildPromoCard(
                'https://images.unsplash.com/photo-1574267432644-f610f65fb1c0?w=800&fit=crop',
                'BUY WICKED: FOR GOOD TICKET & COMBO DI CGV HANYA IDR 99K',
                '2 DAYS AGO',
              ),
              const SizedBox(height: 16),
              _buildPromoCard(
                'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&fit=crop',
                'STAY IN THE EMERALD CITY WITH WICKED COMBO',
                '3 DAYS AGO',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNewsCard(
          'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?w=800&fit=crop',
          '19 FILM TERBARU NOVEMBER 2025: DARI ACTION, HORROR, SAMPAI KONSER IDOL KPOP!',
          '05 NOV 2025',
        ),
        const SizedBox(height: 16),
        _buildNewsCard(
          'https://images.unsplash.com/photo-1594908900066-3f47337549d8?w=800&fit=crop',
          'FESTIVAL FILM ASEAN-KOREA FILM FESTIVAL (AKFF) 2025',
          '2 DAYS AGO',
        ),
        const SizedBox(height: 16),
        _buildNewsCard(
          'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&fit=crop',
          'NNG CINEMA GRAND MALL LAMPUNG OPEN NOW!',
          '7 DAYS AGO',
        ),
        const SizedBox(height: 16),
        _buildNewsCard(
          'https://images.unsplash.com/photo-1524985069026-dd778a71c7b4?w=800&fit=crop',
          'CEK JADWAL TAYANG 5 FILM SEKUEL YANG TAYANG NOVEMBER 2025!',
          '7 DAYS AGO',
        ),
      ],
    );
  }

  Widget _buildPromoCard(String imageUrl, String title, String date) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: $title'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
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
                        child: Icon(Icons.image, size: 64, color: Colors.white38),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildNewsCard(String imageUrl, String title, String date) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reading: $title'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
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
                        child: Icon(Icons.article, size: 64, color: Colors.white38),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
