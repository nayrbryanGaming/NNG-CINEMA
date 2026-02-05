import 'package:flutter/material.dart';
import 'user_repository.dart';
import 'user_model.dart';
import 'package:movies_app/admin/audit/audit_repository.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final UserRepository _repo = UserRepository();
  final AuditRepository _audit = AuditRepository();
  List<UserModel> _list = [];
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

  Future<void> _changeRole(UserModel user) async {
    final makeAdmin = !(user.roles.contains('admin'));
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Confirm role change'), content: Text('Set admin = $makeAdmin for ${user.email}?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')), TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes'))]));
    if (ok != true) return;
    final newRoles = List<String>.from(user.roles);
    if (makeAdmin) {
      newRoles.add('admin');
    } else {
      newRoles.remove('admin');
    }
    await _repo.setRole(user.id, newRoles);
    await _audit.logAdminAction(adminId: 'local-admin', action: 'SET_ROLE', target: user.id, before: user.toJson(), after: {'roles': newRoles});
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final u = _list[idx];
                return ListTile(
                  title: Text(u.email),
                  subtitle: Text(u.roles.join(', ')),
                  trailing: ElevatedButton(onPressed: () => _changeRole(u), child: const Text('Toggle Admin')),
                );
              },
            ),
    );
  }
}

