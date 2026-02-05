import 'package:flutter/material.dart';
import 'schedule_repository.dart';
import 'schedule_model.dart';

class SchedulesListPage extends StatefulWidget {
  const SchedulesListPage({Key? key}) : super(key: key);

  @override
  State<SchedulesListPage> createState() => _SchedulesListPageState();
}

class _SchedulesListPageState extends State<SchedulesListPage> {
  final ScheduleRepository _repo = ScheduleRepository();
  List<ScheduleModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // For demo, load all (not efficient)
    _list = await _repo.listForCinema('');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final s = _list[idx];
                return ListTile(
                  title: Text('Movie ${s.movieId}'),
                  subtitle: Text('${s.startAt} → ${s.endAt} @ ${s.cinemaId}/${s.hallId}'),
                );
              },
            ),
    );
  }
}

