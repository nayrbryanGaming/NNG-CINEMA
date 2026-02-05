import 'package:flutter/material.dart';
import 'audit_repository.dart';
import 'audit_model.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({Key? key}) : super(key: key);

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final AuditRepository _repo = AuditRepository();
  List<AuditModel> _list = [];
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
      appBar: AppBar(title: const Text('Audit Log')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final a = _list[idx];
                return ListTile(
                  title: Text(a.action),
                  subtitle: Text('${a.adminId} • ${a.entityType}/${a.entityId} • ${a.timestamp}'),
                );
              },
            ),
    );
  }
}

