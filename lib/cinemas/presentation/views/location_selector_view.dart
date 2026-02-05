import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_values.dart';

class LocationSelectorView extends StatefulWidget {
  const LocationSelectorView({super.key});

  @override
  State<LocationSelectorView> createState() => _LocationSelectorViewState();
}

class _LocationSelectorViewState extends State<LocationSelectorView> {
  String? selectedLocation = 'MAKASSAR'; // Default location
  String searchQuery = '';

  final List<Map<String, dynamic>> locations = [
    {'name': 'MAKASSAR', 'isCurrent': true},
    {'name': 'BALIKPAPAN', 'isCurrent': false},
    {'name': 'MATARAM', 'isCurrent': false},
    {'name': 'SAMARINDA', 'isCurrent': false},
    {'name': 'JEMBER', 'isCurrent': false},
    {'name': 'PROBOLINGGO', 'isCurrent': false},
    {'name': 'SURABAYA', 'isCurrent': false},
    {'name': 'GRESIK', 'isCurrent': false},
    {'name': 'MOJOKERTO', 'isCurrent': false},
    {'name': 'MALANG', 'isCurrent': false},
    {'name': 'BLITAR', 'isCurrent': false},
    {'name': 'KEDIRI', 'isCurrent': false},
    {'name': 'MADIUN', 'isCurrent': false},
  ];

  List<Map<String, dynamic>> get filteredLocations {
    if (searchQuery.isEmpty) {
      return locations;
    }
    return locations
        .where((location) =>
            location['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Choose Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(AppPadding.p16),
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey[700]!, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Location List
          Expanded(
            child: ListView.separated(
              itemCount: filteredLocations.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[800],
                height: 1,
                indent: AppPadding.p16,
                endIndent: AppPadding.p16,
              ),
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                final isSelected = location['name'] == selectedLocation;
                final isCurrent = location['isCurrent'] as bool;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p16,
                    vertical: AppPadding.p8,
                  ),
                  title: Row(
                    children: [
                      Text(
                        location['name'],
                        style: TextStyle(
                          color: isSelected || isCurrent ? Colors.red : Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected || isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '• Current Location',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    setState(() {
                      selectedLocation = location['name'];
                    });
                    // Update the selected location and navigate back
                    Future.delayed(const Duration(milliseconds: 200), () {
                      context.pop(selectedLocation);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

