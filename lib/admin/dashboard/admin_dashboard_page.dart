// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String _query = '';
  String _statusFilter = 'All';
  DateTimeRange? _dateRange;
  int _page = 0;
  int _rowsPerPage = 6;

  // Sample orders data (replace with API fetch in production)
  late final List<Map<String, dynamic>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = List.generate(28, (i) => {
          'id': 1000 + i,
          'amount': (i + 1) * 25000,
          'status': i % 4 == 0 ? 'Paid' : (i % 4 == 1 ? 'Pending' : (i % 4 == 2 ? 'Refunded' : 'Processing')),
          'customer': 'Customer ${i + 1}',
          'items': List.generate(1 + (i % 3), (j) => 'Item ${j + 1}'),
          'date': DateTime.now().subtract(Duration(hours: i * 6)),
        });
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final q = _query.trim().toLowerCase();
    return _orders.where((o) {
      if (q.isNotEmpty) {
        final matchesId = o['id'].toString().contains(q);
        final matchesCustomer = (o['customer'] as String).toLowerCase().contains(q);
        if (!matchesId && !matchesCustomer) return false;
      }
      if (_statusFilter != 'All' && o['status'] != _statusFilter) return false;
      if (_dateRange != null) {
        final d = o['date'] as DateTime;
        if (d.isBefore(_dateRange!.start) || d.isAfter(_dateRange!.end)) return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _pagedOrders {
    final list = _filteredOrders;
    final start = _page * _rowsPerPage;
    return list.skip(start).take(_rowsPerPage).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: _dateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(dialogBackgroundColor: const Color(0xFF111111)), child: child!),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _statusFilter = 'All';
      _dateRange = null;
      _page = 0;
    });
  }

  void _signOut() async {
    await sl<AuthService>().signOut();
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0D0D0D),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Order #${order['id']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_currency.format(order['amount']), style: const TextStyle(color: Colors.white70)),
              ]),
              const SizedBox(height: 8),
              Text('Customer: ${order['customer']}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Status: ${order['status']}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              const Text('Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((order['items'] as List).map((i) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('- $i', style: const TextStyle(color: Colors.white70)))).toList()),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as refunded (simulated)'))); }, child: const Text('Refund')),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  void _exportCsv() {
    // Placeholder: export logic would go here (server-side or device file write)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export CSV (simulated)')));
  }

  Widget _kpiRow() {
    Widget kpi(String label, String value, IconData icon, Color color) => Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1D1D1D))),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])
          ]),
        );

    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [kpi('Movies', '128', Icons.movie, Colors.deepPurple), const SizedBox(width: 12), kpi('Cinemas', '6', Icons.location_city, Colors.blue), const SizedBox(width: 12), kpi('Orders (24h)', '73', Icons.receipt, Colors.green), const SizedBox(width: 12), kpi('Revenue (24h)', _currency.format(65000000), Icons.trending_up, Colors.orange)]));
  }

  Widget _sparkline(List<int> data) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, lineColor: Colors.orangeAccent),
        size: const Size(double.infinity, 60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = sl.isRegistered<AuthService>() ? sl<AuthService>().currentUser?.email ?? 'admin@local' : 'admin@local';
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070707),
        elevation: 0,
        title: Row(
          children: [
            const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(6)),
              child: const Text('PRO', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _exportCsv, icon: const Icon(Icons.file_download_outlined)),
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Settings'), content: Text('Admin settings placeholder'))),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(email, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    Text('Administrator', style: TextStyle(fontSize: 11, color: Colors.white38)),
                  ],
                ),
                const SizedBox(width: 12),
                InkWell(onTap: _signOut, child: const CircleAvatar(child: Icon(Icons.logout, color: Colors.white), backgroundColor: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // KPI row
              _kpiRow(),
              const SizedBox(height: 12),
              // Filters
              Card(
                color: const Color(0xFF0F0F0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search orders or customers',
                          filled: true,
                          fillColor: const Color(0xFF181818),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _statusFilter,
                              items: ['All', 'Paid', 'Pending', 'Processing', 'Refunded']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                              decoration: InputDecoration(filled: true, fillColor: const Color(0xFF181818), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(onPressed: _pickDateRange, icon: const Icon(Icons.date_range)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quick Actions
              Card(
                color: const Color(0xFF0F0F0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/admin/movies/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Movie'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/admin/movies'),
                        icon: const Icon(Icons.list),
                        label: const Text('Manage Movies'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/admin/data'),
                        icon: const Icon(Icons.dataset),
                        label: const Text('Manage Data'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/admin/cinemas'),
                        icon: const Icon(Icons.location_city),
                        label: const Text('Manage Cinemas'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/admin/orders'),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('View Orders'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/admin/profile'),
                        icon: const Icon(Icons.person),
                        label: const Text('Admin Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Revenue chart
              Card(
                color: const Color(0xFF0F0F0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Revenue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _sparkline(List.generate(20, (i) => (i * 10) + (i % 3 == 0 ? 50 : 0))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Recent Orders Table
              Card(
                color: const Color(0xFF0F0F0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Orders', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFF0E0E0E)),
                          dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFF121212)),
                          columns: const [
                            DataColumn(label: Text('Order ID', style: TextStyle(color: Colors.white70))),
                            DataColumn(label: Text('Customer', style: TextStyle(color: Colors.white70))),
                            DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white70))),
                            DataColumn(label: Text('Status', style: TextStyle(color: Colors.white70))),
                            DataColumn(label: Text('Date', style: TextStyle(color: Colors.white70))),
                            DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white70))),
                          ],
                          rows: _pagedOrders.map((o) {
                            final id = o['id'];
                            final amount = o['amount'];
                            final status = o['status'];
                            final date = o['date'] as DateTime;
                            return DataRow(cells: [
                              DataCell(Text('#$id', style: const TextStyle(color: Colors.white))),
                              DataCell(Text(o['customer'], style: const TextStyle(color: Colors.white70))),
                              DataCell(Text(_currency.format(amount), style: const TextStyle(color: Colors.white70))),
                              DataCell(Text(status, style: TextStyle(color: status == 'Paid' ? Colors.green : (status == 'Pending' ? Colors.orange : Colors.white38)))),
                              DataCell(Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: Colors.white70))),
                              DataCell(Row(children: [
                                IconButton(onPressed: () => _showOrderDetails(o), icon: const Icon(Icons.remove_red_eye, color: Colors.white70)),
                                IconButton(onPressed: () { setState(() { o['status'] = 'Refunded'; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refunded (simulated)'))); }, icon: const Icon(Icons.restart_alt, color: Colors.white70)),
                              ])),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Pagination controls
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Showing \\${(_page * _rowsPerPage) + 1} - \\${((_page * _rowsPerPage) + _pagedOrders.length)} of \\${_filteredOrders.length}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  IconButton(onPressed: _page > 0 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_left, color: Colors.white70)),
                  IconButton(onPressed: ((_page + 1) * _rowsPerPage) < _filteredOrders.length ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_right, color: Colors.white70)),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _rowsPerPage,
                    dropdownColor: const Color(0xFF0F0F0F),
                    items: [6, 12, 24].map((e) => DropdownMenuItem(value: e, child: Text('\\$e'))).toList(),
                    onChanged: (v) => setState(() {
                      _rowsPerPage = v ?? 6;
                      _page = 0;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // System info
              Card(
                color: const Color(0xFF0F0F0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('System', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Version: 1.0.0', style: TextStyle(color: Colors.white38)),
                    const SizedBox(height: 8),
                    Text('Environment: Production', style: TextStyle(color: Colors.white38)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple sparkline custom painter (lightweight, no external deps)
class _SparklinePainter extends CustomPainter {
  final List<int> data;
  final Color lineColor;

  _SparklinePainter({required this.data, this.lineColor = Colors.orange});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = lineColor..strokeWidth = 2..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    if (data.isEmpty) return;
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();
    final min = data.reduce((a, b) => a < b ? a : b).toDouble();
    final range = (max - min) == 0 ? 1 : (max - min);
    final step = size.width / (data.length - 1);
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - ((data[i] - min) / range) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    // shade
    final fill = Paint()..shader = LinearGradient(colors: [lineColor.withOpacity(0.12), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fillPath, fill);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.data != data || oldDelegate.lineColor != lineColor;
}
