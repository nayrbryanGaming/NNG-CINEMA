import 'package:flutter/material.dart';

class AdminDataListPage extends StatelessWidget {
  const AdminDataListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (i) => {'id': i + 1, 'title': 'Data Item ${i + 1}', 'subtitle': 'Subtitle ${i + 1}'});

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Data')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              title: Text(item['title'] as String),
              subtitle: Text(item['subtitle'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pushNamed('/admin/movies/${item['id']}/edit'),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete'),
                          content: const Text('Confirm delete?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Deleted (simulated)')));
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/admin/movies/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
