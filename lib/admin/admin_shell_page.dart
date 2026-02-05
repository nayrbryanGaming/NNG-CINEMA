import 'package:flutter/material.dart';
import 'package:movies_app/admin/shared/admin_drawer.dart';

class AdminShellPage extends StatelessWidget {
  final Widget child;
  const AdminShellPage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      drawer: const AdminDrawer(),
      body: child,
    );
  }
}

