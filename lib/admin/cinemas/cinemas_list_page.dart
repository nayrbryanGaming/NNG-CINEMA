import 'package:flutter/material.dart';
import 'cinema_repository.dart';
import 'cinema_model.dart';

class CinemasListPage extends StatefulWidget {
  const CinemasListPage({Key? key}) : super(key: key);

  @override
  State<CinemasListPage> createState() => _CinemasListPageState();
}

class _CinemasListPageState extends State<CinemasListPage> {
  final CinemaRepository _repo = CinemaRepository();
  List<CinemaModel> _list = [];
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
      appBar: AppBar(title: const Text('Cinemas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final c = _list[idx];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text('${c.city} • ${c.address}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        // TODO: navigate to edit
                      } else if (v == 'delete') {
                        final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Confirm'), content: const Text('Delete cinema?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')), TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes'))]));
                        if (ok == true) {
                          await _repo.delete(c.id);
                          await _load();
                        }
                      }
                    },
                    itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                  ),
                );
              },
            ),
    );
  }
}

