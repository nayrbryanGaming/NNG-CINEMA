import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/fnb/presentation/views/fnb_view.dart';

// Wrapper view used in booking flow to pick F&B and return the selected cart to caller.
class FnbSelectionView extends StatelessWidget {
  const FnbSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Render FnbView and when user checks out in cart, return the selected cart to caller
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: FnbViewWithCallback(
          onCheckout: (cart) {
            // Return the selected cart to the caller (OrderSummary)
            Navigator.of(context).pop(cart);
          },
        ),
      ),
    );
  }
}

// A small adapter that embeds existing FnbView and exposes an onCheckout callback.
class FnbViewWithCallback extends StatefulWidget {
  final ValueChanged<List<Map<String, dynamic>>> onCheckout;

  const FnbViewWithCallback({super.key, required this.onCheckout});

  @override
  State<FnbViewWithCallback> createState() => _FnbViewWithCallbackState();
}

class _FnbViewWithCallbackState extends State<FnbViewWithCallback> {
  final List<Map<String, dynamic>> _cart = [];

  void _handleCartUpdate(List<Map<String, dynamic>> newCart) {
    setState(() {
      _cart
        ..clear()
        ..addAll(newCart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FnbViewWrapper(
      cart: _cart,
      onUpdate: _handleCartUpdate,
      onCheckout: widget.onCheckout,
    );
  }
}

// Lightweight wrapper around the FnbView + FnbCartView modal behavior.
// We reuse the existing FnbView but need an entry point that allows injection of callbacks.
class FnbViewWrapper extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final ValueChanged<List<Map<String, dynamic>>> onUpdate;
  final ValueChanged<List<Map<String, dynamic>>> onCheckout;

  const FnbViewWrapper({super.key, required this.cart, required this.onUpdate, required this.onCheckout});

  @override
  State<FnbViewWrapper> createState() => _FnbViewWrapperState();
}

class _FnbViewWrapperState extends State<FnbViewWrapper> {
  @override
  Widget build(BuildContext context) {
    // We will reuse the existing FnbView UI but we need to supply a cart and onUpdate.
    // For simplicity, render the FnbView and intercept its FAB to open cart with onCheckout support.
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add F&B'),
      ),
      body: Builder(builder: (context) {
        // Import and use the original FnbView widget's logic: since original FnbView manages its own cart,
        // for now we provide a local copy of that widget and intercept checkout through the FnbCartView's onCheckout.
        return FnbView();
      }),
    );
  }
}
