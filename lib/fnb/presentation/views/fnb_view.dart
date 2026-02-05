import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/fnb/presentation/views/fnb_cart_view.dart';

class FnbView extends StatefulWidget {
  final ValueChanged<List<Map<String, dynamic>>>? onCheckout;

  const FnbView({super.key, this.onCheckout});

  @override
  State<FnbView> createState() => _FnbViewState();
}

class _FnbViewState extends State<FnbView> {
  String selectedCategory = 'ALL';
  String selectedLocation = 'Panakkukang Square';
  String searchQuery = '';

  final List<String> categories = [
    'ALL',
    'COMBO',
    'POPCORN',
    'DRINK CONCESSION',
    'FOOD CONCESSION',
    'PROMO COMBO',
  ];

  // Static menu data
  final List<Map<String, dynamic>> _allItems = [
    // COMBO
    {'name': 'Combo Duo', 'desc': '2 Beverages + 1 Popcorn', 'price': 95000, 'category': 'COMBO', 'image': 'https://images.unsplash.com/photo-1585238341710-4f5b4c2c6d99?w=400'},
    {'name': 'Combo Solo', 'desc': '1 Beverages + 1 Popcorn', 'price': 68000, 'category': 'COMBO', 'image': 'https://images.unsplash.com/photo-1585238341710-4f5b4c2c6d99?w=400'},

    // POPCORN
    {'name': 'Large Caramel Popcorn', 'desc': 'Popcorn coated with caramel in Large size', 'price': 80000, 'category': 'POPCORN', 'image': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400'},
    {'name': 'Large Mix Popcorn', 'desc': 'Mixed popcorn caramel & salty in Large size', 'price': 80000, 'category': 'POPCORN', 'image': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400'},
    {'name': 'Large Salty Popcorn', 'desc': 'Popcorn salty taste in Medium size', 'price': 70000, 'category': 'POPCORN', 'image': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400'},
    {'name': 'Medium Caramel Popcorn', 'desc': 'Popcorn coated with caramel in Medium size', 'price': 57000, 'category': 'POPCORN', 'image': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400'},
    {'name': 'Medium Salty Popcorn', 'desc': 'Popcorn salty taste in Medium size', 'price': 45000, 'category': 'POPCORN', 'image': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400'},

    // DRINK CONCESSION
    {'name': 'Large Coca Cola', 'desc': 'Paper cup 32oz', 'price': 40000, 'category': 'DRINK CONCESSION', 'image': 'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400'},
    {'name': 'Large Cola Zero', 'desc': '', 'price': 40000, 'category': 'DRINK CONCESSION', 'image': 'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400'},
    {'name': 'Large Fanta', 'desc': '', 'price': 40000, 'category': 'DRINK CONCESSION', 'image': 'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400'},
    {'name': 'Large Sprite', 'desc': '32oz size Sprite', 'price': 40000, 'category': 'DRINK CONCESSION', 'image': 'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400'},
    {'name': 'Medium Coca Cola', 'desc': 'Paper cup 22oz', 'price': 36000, 'category': 'DRINK CONCESSION', 'image': 'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400'},

    // FOOD CONCESSION
    {'name': 'NNG Sampler', 'desc': 'Platter of Fried Siomay, French Fries & Fishball', 'price': 60000, 'category': 'FOOD CONCESSION', 'image': 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=400'},
    {'name': 'Chicken Popcorn & Fries', 'desc': 'Chicken Popcorn and fries', 'price': 55000, 'category': 'FOOD CONCESSION', 'image': 'https://images.unsplash.com/photo-1562967916-eb82221dfb92?w=400'},
    {'name': 'French Fries', 'desc': 'Fried straight cut potato', 'price': 50000, 'category': 'FOOD CONCESSION', 'image': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400'},
    {'name': 'Fried Fishball', 'desc': '3 pcs stick fishball', 'price': 50000, 'category': 'FOOD CONCESSION', 'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'},
    {'name': 'Fried Siomay', 'desc': '3 pcs stick siomay', 'price': 50000, 'category': 'FOOD CONCESSION', 'image': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400'},

    // PROMO COMBO
    {'name': 'COMBO COLA-BORASI DOUBLE', 'desc': '1 M. Popcorn + 2 M. Soft Drink', 'price': 95000, 'category': 'PROMO COMBO', 'image': 'https://images.unsplash.com/photo-1585238341710-4f5b4c2c6d99?w=400'},
    {'name': 'Combo Cola-borasi Single', 'desc': '1 M. Popcorn + 1 M. Soft Drink', 'price': 68000, 'category': 'PROMO COMBO', 'image': 'https://images.unsplash.com/photo-1585238341710-4f5b4c2c6d99?w=400'},
  ];

  List<Map<String, dynamic>> get filteredItems {
    var items = _allItems;
    if (selectedCategory != 'ALL') {
      items = items.where((item) => item['category'] == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      items = items.where((item) =>
          (item['name'] as String).toLowerCase().contains(searchQuery.toLowerCase()) ||
          (item['desc'] as String).toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    return items;
  }

  // In-memory cart: each entry {name, price, qty, image}
  final List<Map<String, dynamic>> _cart = [];

  int get _cartCount => _cart.fold<int>(0, (p, e) => p + (e['qty'] as int));

  void _addToCart(Map<String, dynamic> item) {
    final existing = _cart.indexWhere((e) => e['name'] == item['name']);
    setState(() {
      if (existing >= 0) {
        _cart[existing]['qty'] = (_cart[existing]['qty'] as int) + 1;
      } else {
        _cart.add({'name': item['name'], 'price': item['price'], 'qty': 1, 'image': item['image']});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Dark background like the app theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button - this is a main page
        title: const Text(
          'Popcorn Zone',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: 'Riwayat Pesanan',
            onPressed: () => context.goNamed(AppRoutes.fnbOrdersRoute),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => FractionallySizedBox(
              heightFactor: 0.9,
              child: FnbCartView(cart: _cart, onUpdate: (newCart) {
                setState(() {
                  _cart
                    ..clear()
                    ..addAll(newCart);
                });
              }, onCheckout: widget.onCheckout),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.black),
            if (_cartCount > 0)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$_cartCount', style: const TextStyle(fontSize: 12, color: Colors.white)),
                ),
              )
          ],
        ),
      ),
      body: Column(
        children: [
          // Location header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade800, Colors.red.shade600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedLocation,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showLocationPicker(context);
                  },
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Category tabs
          Container(
            height: 50,
            color: Colors.black,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Menu items list
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildMenuItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item['desc'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item['desc'],
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Rp${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Add button
          OutlinedButton(
            onPressed: () {
              _addToCart(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} added to cart'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'ADD',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    final locations = [
      'Panakkukang Square',
      'Trans Studio Mall',
      'Mall Ratu Indah',
      'Nipah Mall',
      'Pettarani',
      'Makassar Town Square',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Lokasi Cinema',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.white24),
            ...locations.map((loc) => ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(loc, style: const TextStyle(color: Colors.white)),
              trailing: selectedLocation == loc
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedLocation = loc;
                });
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String tempQuery = searchQuery;
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Cari Menu', style: TextStyle(color: Colors.white)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nama menu atau deskripsi...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            controller: TextEditingController(text: searchQuery),
            onChanged: (val) => tempQuery = val,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
                Navigator.pop(ctx);
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = tempQuery;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );
  }
}

