import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Supported payment methods for F&B orders.
enum PaymentMethod { qris, bankTransfer, eWallet }

/// Payment status lifecycle for an order.
enum PaymentStatus { pending, paid, cancelled }

/// Line item inside an F&B order.
class FnbOrderItem {
  final String name;
  final int price;
  final int qty;
  final String? image;

  const FnbOrderItem({
    required this.name,
    required this.price,
    required this.qty,
    this.image,
  });

  int get subtotal => price * qty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'qty': qty,
        'image': image,
      };

  factory FnbOrderItem.fromJson(Map<String, dynamic> json) => FnbOrderItem(
        name: json['name'] as String,
        price: json['price'] as int,
        qty: json['qty'] as int,
        image: json['image'] as String?,
      );
}

/// Aggregate order model for F&B checkout.
class FnbOrder {
  final String id;
  final List<FnbOrderItem> items;
  final int total;
  final PaymentMethod method;
  PaymentStatus status;
  final DateTime createdAt;
  final String qrContent; // Code shown for pickup / payment confirmation

  FnbOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.qrContent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'method': method.index,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'qrContent': qrContent,
      };

  factory FnbOrder.fromJson(Map<String, dynamic> json) => FnbOrder(
        id: json['id'] as String,
        items: (json['items'] as List).map((e) => FnbOrderItem.fromJson(Map<String, dynamic>.from(e))).toList(),
        total: json['total'] as int,
        method: PaymentMethod.values[json['method'] as int],
        status: PaymentStatus.values[json['status'] as int],
        createdAt: DateTime.parse(json['createdAt'] as String),
        qrContent: json['qrContent'] as String,
      );
}

/// Persistent service to manage F&B orders using Hive for local storage.
class FnbOrderService extends ChangeNotifier {
  static const String _boxName = 'fnb_orders_box';
  static final FnbOrderService _instance = FnbOrderService._internal();

  factory FnbOrderService() => _instance;

  FnbOrderService._internal();

  final List<FnbOrder> _orders = [];
  bool _initialized = false;

  UnmodifiableListView<FnbOrder> get orders => UnmodifiableListView(_orders);

  /// Initialize service and load orders from Hive
  Future<void> initialize() async {
    if (_initialized) return;
    await _loadFromBox();
    _initialized = true;
  }

  Future<Box<dynamic>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> _loadFromBox() async {
    try {
      final box = await _openBox();
      final raw = box.get('orders');
      if (raw is List) {
        _orders.clear();
        for (final item in raw) {
          try {
            final map = Map<String, dynamic>.from(item as Map);
            _orders.add(FnbOrder.fromJson(map));
          } catch (_) {}
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FnbOrderService] Failed to load orders: $e');
      }
    }
  }

  Future<void> _saveToBox() async {
    try {
      final box = await _openBox();
      final serialized = _orders.map((o) => o.toJson()).toList();
      await box.put('orders', serialized);
    } catch (e) {
      if (kDebugMode) {
        print('[FnbOrderService] Failed to save orders: $e');
      }
    }
  }

  Future<FnbOrder> createOrderFromCart(List<Map<String, dynamic>> cart, PaymentMethod method) async {
    await initialize();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final items = cart
        .map((e) => FnbOrderItem(
              name: e['name'] as String,
              price: e['price'] as int,
              qty: e['qty'] as int,
              image: e['image'] as String?,
            ))
        .toList();
    final total = items.fold<int>(0, (p, e) => p + e.subtotal);
    final qrContent = 'FNB-$id-$total-${method.name.toUpperCase()}';
    final order = FnbOrder(
      id: id,
      items: items,
      total: total,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      qrContent: qrContent,
    );
    _orders.insert(0, order); // latest first
    await _saveToBox();
    notifyListeners();
    return order;
  }

  Future<void> markPaid(String orderId) async {
    await initialize();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].status = PaymentStatus.paid;
      await _saveToBox();
      notifyListeners();
    }
  }

  FnbOrder? getById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAllOrders() async {
    _orders.clear();
    await _saveToBox();
    notifyListeners();
  }
}

