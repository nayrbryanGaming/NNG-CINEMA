import 'package:flutter/material.dart';
import 'order_repository.dart';
import 'order_model.dart';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  final OrderRepository _repo = OrderRepository();
  List<OrderModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _list = await _repo.list();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final o = _list[idx];
                return ListTile(
                  title: Text('Order ${o.id} - ${o.totalPrice}'),
                  subtitle: Text('${o.seats.join(', ')} • ${o.status}'),
                  onTap: () => Navigator.of(context).pushNamed('/admin/orders/${o.id}'),
                );
              },
            ),
    );
  }
}

