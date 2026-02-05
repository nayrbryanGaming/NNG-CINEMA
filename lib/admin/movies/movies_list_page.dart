import 'package:flutter/material.dart';
import 'movie_repository.dart';
import 'movie_model.dart';

class MoviesListPage extends StatefulWidget {
  const MoviesListPage({Key? key}) : super(key: key);

  @override
  State<MoviesListPage> createState() => _MoviesListPageState();
}

class _MoviesListPageState extends State<MoviesListPage> {
  final MovieRepository _repo = MovieRepository();
  bool _loading = true;
  List<MovieModel> _movies = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _movies = await _repo.list(limit: 50);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, idx) {
                final m = _movies[idx];
                return ListTile(
                  leading: m.posterUrl != null ? Image.network(m.posterUrl!, width: 48, fit: BoxFit.cover) : const SizedBox(width: 48),
                  title: Text(m.title),
                  subtitle: Text('${m.genres.join(', ')} • ${m.durationMinutes}m'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.of(context).pushNamed('/admin/movies/${m.id}/edit');
                      } else if (v == 'delete') {
                        final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Confirm'), content: const Text('Delete movie?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')), TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes'))]));
                        if (ok == true) {
                          await _repo.delete(m.id);
                          await _load();
                        }
                      }
                    },
                    itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
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

