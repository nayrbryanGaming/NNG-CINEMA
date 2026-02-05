import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FnbView extends StatefulWidget {
  const FnbView({super.key});
  @override
  State<FnbView> createState() => _FnbViewState();
}

class _FnbViewState extends State<FnbView> {
  final tabs = ['ALL','COMBO','POPCORN','DRINK CONCESSION','FOOD CONCESSION','PROMO COMBO'];
  int selected = 0;
  bool _seedDone = false;
  bool _seedFailed = false;

  Future<void> _seedIfEmpty() async {
    try {
      final col = FirebaseFirestore.instance.collection('fnb');
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) {
        setState(() => _seedDone = true);
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      final items = [
        // COMBO - Using actual image URLs
        {
          'category':'COMBO','name':'Combo Duo','desc':'2 Beverages + 1 Popcorn','price':95000,
          'image':'https://images.unsplash.com/photo-1585647347483-22b66260dfff?w=400&h=400&fit=crop',
          'emoji':'🍿🥤🥤'
        },
        {
          'category':'COMBO','name':'Combo Solo','desc':'1 Beverage + 1 Popcorn','price':68000,
          'image':'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop',
          'emoji':'🍿🥤'
        },
        // POPCORN
        {
          'category':'POPCORN','name':'Large Caramel Popcorn','desc':'Caramel coated large size','price':80000,
          'image':'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=400&h=400&fit=crop',
          'emoji':'🍿'
        },
        {
          'category':'POPCORN','name':'Large Mix Popcorn','desc':'Mixed caramel & salty large','price':80000,
          'image':'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop',
          'emoji':'🍿'
        },
        {
          'category':'POPCORN','name':'Large Salty Popcorn','desc':'Salty taste large size','price':70000,
          'image':'https://images.unsplash.com/photo-1585647347483-22b66260dfff?w=400&h=400&fit=crop',
          'emoji':'🍿'
        },
        {
          'category':'POPCORN','name':'Medium Caramel Popcorn','desc':'Caramel medium size','price':57000,
          'image':'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=400&h=400&fit=crop',
          'emoji':'🍿'
        },
        {
          'category':'POPCORN','name':'Medium Salty Popcorn','desc':'Salty medium size','price':45000,
          'image':'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop',
          'emoji':'🍿'
        },
        // DRINK CONCESSION
        {
          'category':'DRINK CONCESSION','name':'Large Coca Cola','desc':'Paper cup 32oz','price':40000,
          'image':'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&h=400&fit=crop',
          'emoji':'🥤'
        },
        {
          'category':'DRINK CONCESSION','name':'Large Cola Zero','desc':'Sugar free 32oz','price':40000,
          'image':'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=400&h=400&fit=crop',
          'emoji':'🥤'
        },
        {
          'category':'DRINK CONCESSION','name':'Large Fanta','desc':'32oz size','price':40000,
          'image':'https://images.unsplash.com/photo-1625772452859-1c03d5bf1137?w=400&h=400&fit=crop',
          'emoji':'🥤'
        },
        {
          'category':'DRINK CONCESSION','name':'Large Sprite','desc':'32oz size Sprite','price':40000,
          'image':'https://images.unsplash.com/photo-1581098365948-6a5a912b7a49?w=400&h=400&fit=crop',
          'emoji':'🥤'
        },
        // FOOD CONCESSION
        {
          'category':'FOOD CONCESSION','name':'CGV Sampler','desc':'Siomay, Fries & Fishball','price':60000,
          'image':'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&h=400&fit=crop',
          'emoji':'🍱'
        },
        {
          'category':'FOOD CONCESSION','name':'Chicken Popcorn & Fries','desc':'Chicken popcorn + fries','price':55000,
          'image':'https://images.unsplash.com/photo-1562967916-7c9c0097e5d4?w=400&h=400&fit=crop',
          'emoji':'🍗🍟'
        },
        {
          'category':'FOOD CONCESSION','name':'French Fries','desc':'Straight cut potato','price':50000,
          'image':'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&h=400&fit=crop',
          'emoji':'🍟'
        },
        {
          'category':'FOOD CONCESSION','name':'Fried Fishball','desc':'3 pcs stick fishball','price':50000,
          'image':'https://images.unsplash.com/photo-1589621316382-008455b857cd?w=400&h=400&fit=crop',
          'emoji':'🍢'
        },
        {
          'category':'FOOD CONCESSION','name':'Fried Siomay','desc':'Steamed & fried siomay','price':50000,
          'image':'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&h=400&fit=crop',
          'emoji':'🥟'
        },
        // PROMO COMBO
        {
          'category':'PROMO COMBO','name':'Combo Cola-Borasi Double','desc':'1 M. Popcorn + 2 M. Soft Drink','price':95000,
          'image':'https://images.unsplash.com/photo-1585647347483-22b66260dfff?w=400&h=400&fit=crop',
          'emoji':'🎉🍿🥤'
        },
        {
          'category':'PROMO COMBO','name':'Combo Cola-Borasi Single','desc':'1 M. Popcorn + 1 M. Soft Drink','price':68000,
          'image':'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop',
          'emoji':'🎉🍿'
        },
      ];
      for (final item in items) {
        final doc = col.doc();
        batch.set(doc, item);
      }
      await batch.commit();
      setState(() => _seedDone = true);
    } catch (e) {
      setState(() => _seedFailed = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _seedIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Popcorn Zone'),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationHeader(),
          _buildTabs(),
          Expanded(child: _buildCategoryList()),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.red, Colors.orange]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(child: Text('Panakkukang Square', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          TextButton(onPressed: (){}, child: const Text('CHANGE', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(tabs.length, (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(tabs[i], style: const TextStyle(fontSize: 12)),
            selected: selected == i,
            onSelected: (_) => setState(() => selected = i),
            selectedColor: Colors.red,
            backgroundColor: Colors.black,
            labelStyle: TextStyle(color: selected==i? Colors.white: Colors.white70),
          ),
        )),
      ),
    );
  }

  Widget _buildCategoryList() {
    final selectedCategory = tabs[selected];
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fnb').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Error memuat data', style: TextStyle(color: Colors.white)));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          if (_seedFailed) {
            return const Center(child: Text('Gagal seeding. Coba ulang.', style: TextStyle(color: Colors.white)));
          }
          return const Center(child: Text('Menyiapkan menu...', style: TextStyle(color: Colors.white)));
        }
        final filtered = selectedCategory == 'ALL'
            ? docs
            : docs.where((d) => (d.data() as Map<String, dynamic>)['category'] == selectedCategory).toList();
        if (filtered.isEmpty) {
          return Center(child: Text('Tidak ada item untuk $selectedCategory', style: const TextStyle(color: Colors.white)));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[850],
                      child: data['image'] != null
                          ? Image.network(
                              data['image'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to emoji if image fails
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Text(
                                      data['emoji'] ?? '🍔',
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                data['emoji'] ?? '🍔',
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data['name'] ?? 'Unnamed').toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (data['desc'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              data['desc'].toString(),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp${data['price'] ?? 0}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${data['name']} ditambahkan')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

