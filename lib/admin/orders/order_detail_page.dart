import 'package:flutter/material.dart';
import 'order_repository.dart';
import 'order_model.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderRepository _repo = OrderRepository();
  OrderModel? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.list();
    _order = list.firstWhere((o) => o.id == widget.orderId, orElse: () => null as OrderModel);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${widget.orderId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${_order!.userId}'),
                      Text('Seats: ${_order!.seats.join(', ')}'),
                      Text('Price: ${_order!.totalPrice}'),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: () async => await _repo.updateStatus(_order!.id, 'cancelled'), child: const Text('Cancel / Refund'))
                    ],
                  ),
                ),
    );
  }
}

