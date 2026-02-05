import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class FaqContactView extends StatefulWidget {
  const FaqContactView({super.key});

  @override
  State<FaqContactView> createState() => _FaqContactViewState();
}

class _FaqContactViewState extends State<FaqContactView> {
  String? _expandedCategory;

  final Map<String, List<Map<String, String>>> _faqData = {
    'NEW NNG CINEMA MEMBERSHIP': [
      {
        'q': 'How do I register for NNG Cinema membership?',
        'a': 'You can register through our mobile app or at the cinema counter. Fill in your personal details and verify your email to activate your account.',
      },
      {
        'q': 'What are the membership tiers?',
        'a': 'We have three tiers: Classic (0 points), Gold (8x visits or Rp850K spend), and VIP (special invitation). Each tier offers different benefits.',
      },
    ],
    'LOST & FOUND': [
      {
        'q': 'I lost something at the cinema, what should I do?',
        'a': 'Please contact our customer service immediately or visit the cinema counter. Provide details about the item and when you visited.',
      },
      {
        'q': 'How long are lost items kept?',
        'a': 'Lost items are kept for 30 days. After that period, unclaimed items will be donated or disposed of according to policy.',
      },
    ],
    'NNG CINEMA MEMBERSHIP': [
      {
        'q': 'How do I earn points?',
        'a': 'You earn points by purchasing tickets and F&B items. Points are automatically added to your account after each transaction.',
      },
      {
        'q': 'Do points expire?',
        'a': 'Yes, points expire after 12 months from the date of earning if not used.',
      },
    ],
    'NNG CINEMA POINT': [
      {
        'q': 'How can I redeem my points?',
        'a': 'You can redeem points for ticket discounts, F&B items, or special merchandise. Check the rewards section in the app.',
      },
      {
        'q': 'Can I transfer points to another account?',
        'a': 'No, points are non-transferable and can only be used by the account holder.',
      },
    ],
    'F&B': [
      {
        'q': 'Can I bring outside food?',
        'a': 'Outside food and beverages are not allowed in the cinema halls. We offer a wide variety of snacks and drinks at our concession stands.',
      },
      {
        'q': 'Do you offer combo deals?',
        'a': 'Yes! We have various combo deals that include popcorn and drinks at discounted prices. Check our F&B menu for current offers.',
      },
    ],
    'PROMOTION': [
      {
        'q': 'How do I use promo codes?',
        'a': 'Enter the promo code during checkout when booking tickets online or show it at the counter for offline purchases.',
      },
      {
        'q': 'Can I use multiple promo codes?',
        'a': 'Typically, only one promo code can be used per transaction, unless specified otherwise.',
      },
    ],
    'PROGRAM': [
      {
        'q': 'What special programs does NNG Cinema offer?',
        'a': 'We offer private screenings, movie marathons, special fan events, and exclusive premieres for members.',
      },
    ],
    'ONLINE': [
      {
        'q': 'How do I book tickets online?',
        'a': 'Download our app, select your movie, cinema, showtime, and seats. Complete payment to receive your booking confirmation.',
      },
      {
        'q': 'Can I cancel my online booking?',
        'a': 'Cancellations must be made at least 2 hours before showtime. A service fee may apply.',
      },
    ],
  };

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
        title: const Text('FAQ & Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Access Buttons
          Row(
            children: [
              Expanded(child: _buildQuickAccessButton(Icons.search, 'Lost & Found')),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickAccessButton(Icons.card_membership, 'Membership')),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickAccessButton(Icons.campaign, 'Ads & Partner')),
            ],
          ),
          const SizedBox(height: 24),

          // FAQ Section
          const Text(
            'Browse by FAQ Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ..._faqData.keys.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFaqCategory(category),
            );
          }),

          const SizedBox(height: 24),

          // Contact Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our customer service team is here to assist you',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Calling +62 811-2233-4455...'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening email client...'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactRow(Icons.phone, 'Hotline', '+62 811-2233-4455'),
                _buildContactRow(Icons.email, 'Email', 'support@nngcinema.com'),
                _buildContactRow(Icons.schedule, 'Working Hours', 'Mon-Sun: 9AM - 10PM'),
                _buildContactRow(Icons.location_on, 'Address', 'Panakkukang Square, Makassar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $label section'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCategory(String category) {
    final isExpanded = _expandedCategory == category;
    final questions = _faqData[category] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategory = isExpanded ? null : category;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Colors.grey, height: 1),
            ...questions.map((qa) {
              return ExpansionTile(
                title: Text(
                  qa['q']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      qa['a']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                iconColor: Colors.red,
                collapsedIconColor: Colors.grey,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
