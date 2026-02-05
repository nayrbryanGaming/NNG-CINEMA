import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  bool _loading = true;
  int _totalUsers = 0;
  int _anonymousUsers = 0;
  int _registeredUsers = 0;
  int _activeToday = 0;
  int _totalOrders = 0;
  int _totalTickets = 0;
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _crashReports = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // Get total users
      final usersSnapshot = await firestore.collection('users').get();
      _totalUsers = usersSnapshot.docs.length;

      // Count anonymous vs registered
      _anonymousUsers = 0;
      _registeredUsers = 0;
      _activeToday = 0;
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['isAnonymous'] == true) {
          _anonymousUsers++;
        } else {
          _registeredUsers++;
        }

        // Check if active today
        final lastLogin = data['lastLoginAt'] as Timestamp?;
        if (lastLogin != null && lastLogin.toDate().isAfter(todayStart)) {
          _activeToday++;
        }
      }

      // Get recent users (last 10)
      final recentUsersSnapshot = await firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      _recentUsers = recentUsersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] ?? data['username'] ?? 'Anonymous',
          'isAnonymous': data['isAnonymous'] ?? false,
          'createdAt': data['createdAt'],
        };
      }).toList();

      // Get total orders (if collection exists)
      try {
        final ordersSnapshot = await firestore.collection('orders').get();
        _totalOrders = ordersSnapshot.docs.length;
      } catch (_) {
        _totalOrders = 0;
      }

      // Get total tickets (if collection exists)
      try {
        final ticketsSnapshot = await firestore.collection('tickets').get();
        _totalTickets = ticketsSnapshot.docs.length;
      } catch (_) {
        _totalTickets = 0;
      }

      // Get crash reports (simulated - would come from Crashlytics API)
      _crashReports = [
        {
          'type': 'Non-fatal',
          'message': 'Network timeout on movie fetch',
          'count': 12,
          'lastOccurred': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'type': 'Crash',
          'message': 'Null pointer in payment flow',
          'count': 3,
          'lastOccurred': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'type': 'ANR',
          'message': 'Main thread blocked on database',
          'count': 5,
          'lastOccurred': DateTime.now().subtract(const Duration(hours: 12)),
        },
      ];

    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Analytics Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Statistics Cards
                    const Text(
                      'User Statistics',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Users',
                          _totalUsers.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Registered',
                          _registeredUsers.toString(),
                          Icons.person_add,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Anonymous',
                          _anonymousUsers.toString(),
                          Icons.person_outline,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Active Today',
                          _activeToday.toString(),
                          Icons.trending_up,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Business Statistics
                    const Text(
                      'Business Metrics',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Orders',
                            _totalOrders.toString(),
                            Icons.shopping_cart,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Tickets Sold',
                            _totalTickets.toString(),
                            Icons.confirmation_number,
                            Colors.pink,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Crash Reports Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Crash Reports',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bug_report, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_crashReports.length} issues',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._crashReports.map((report) => _buildCrashReportCard(report)),

                    const SizedBox(height: 24),

                    // Recent Users
                    const Text(
                      'Recent Users',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _recentUsers.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('No users found', style: TextStyle(color: Colors.white54)),
                                ),
                              ]
                            : _recentUsers.map((user) => _buildUserListItem(user)).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrashReportCard(Map<String, dynamic> report) {
    final typeColor = report['type'] == 'Crash'
        ? Colors.red
        : report['type'] == 'ANR'
            ? Colors.orange
            : Colors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              report['type'],
              style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['message'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last occurred: ${_formatDate(report['lastOccurred'])}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${report['count']}x',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: user['isAnonymous'] ? Colors.orange : Colors.blue,
            child: Icon(
              user['isAnonymous'] ? Icons.person_outline : Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['email'] ?? 'Unknown',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user['isAnonymous'] ? 'Anonymous User' : 'Registered',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          if (user['createdAt'] != null)
            Text(
              _formatDate((user['createdAt'] as Timestamp).toDate()),
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

