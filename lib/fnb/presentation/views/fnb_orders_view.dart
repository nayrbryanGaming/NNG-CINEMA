import 'package:flutter/material.dart';
import 'package:movies_app/fnb/data/fnb_order_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:movies_app/core/services/service_locator.dart';

class FnbOrdersView extends StatefulWidget {
  const FnbOrdersView({super.key});

  @override
  State<FnbOrdersView> createState() => _FnbOrdersViewState();
}

class _FnbOrdersViewState extends State<FnbOrdersView> {
  late FnbOrderService _service;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = sl<FnbOrderService>();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    _service.addListener(_onOrdersChanged);
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _service.removeListener(_onOrdersChanged);
    super.dispose();
  }

  void _onOrdersChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final orders = _service.orders;
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('F&B Orders'),
        backgroundColor: const Color(0xFF141414),
        automaticallyImplyLeading: false, // Don't show back button since this is a main route
        actions: [
          if (orders.isNotEmpty)
            IconButton(
              tooltip: 'Clear all orders (debug)',
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all F&B orders?'),
                    content: const Text('This will delete all saved F&B orders locally. Continue?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _service.clearAllOrders();
                }
              },
            ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fastfood_outlined, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text('Belum ada order F&B', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('Pesan makanan dan minuman favorit Anda!', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = order.status == PaymentStatus.paid ? Colors.green : Colors.orange;
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Order #${order.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Total: Rp${order.total}\nMetode: ${order.method.name.toUpperCase()}\nStatus: ${order.status.name.toUpperCase()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(order.status.name.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => _OrderDetail(orderId: order.id)));
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _OrderDetail extends StatefulWidget {
  final String orderId;
  const _OrderDetail({required this.orderId});

  @override
  State<_OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<_OrderDetail> {
  late FnbOrderService _service;

  @override
  void initState() {
    super.initState();
    _service = sl<FnbOrderService>();
    _service.addListener(_onChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final order = _service.getById(widget.orderId);
    if (order == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: Text('Order tidak ditemukan', style: TextStyle(color: Colors.white))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        backgroundColor: const Color(0xFF141414),
        actions: [
          if (order.status != PaymentStatus.paid)
            TextButton(
              onPressed: () {
                _service.markPaid(order.id);
              },
              child: const Text('Tandai Lunas', style: TextStyle(color: Colors.greenAccent)),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.name.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Metode: ${order.method.name.toUpperCase()}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...order.items.map(
              (i) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(i.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('Qty ${i.qty} x Rp${i.price}', style: const TextStyle(color: Colors.white70)),
                trailing: Text('Rp${i.subtotal}', style: const TextStyle(color: Colors.white)),
              ),
            ),
            const Divider(color: Colors.white24),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: Rp${order.total}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Text('QR Pickup', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: QrImageView(
                data: order.qrContent,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tunjukkan QR ini saat mengambil pesanan.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

