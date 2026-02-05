import 'package:flutter/material.dart';
import 'cinema_repository.dart';
import 'cinema_model.dart';

class CinemaFormPage extends StatefulWidget {
  final String? cinemaId;
  const CinemaFormPage({Key? key, this.cinemaId}) : super(key: key);

  @override
  State<CinemaFormPage> createState() => _CinemaFormPageState();
}

class _CinemaFormPageState extends State<CinemaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;
  final CinemaRepository _repo = CinemaRepository();

  @override
  void initState() {
    super.initState();
    if (widget.cinemaId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Not implemented: fetch by id. For now forms are for create/edit minimal.
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final model = CinemaModel(
        id: widget.cinemaId ?? '',
        name: _name.text.trim(),
        city: _city.text.trim(),
        address: _address.text.trim(),
        halls: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (widget.cinemaId == null) await _repo.create(model);
      else await _repo.update(model);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cinemaId == null ? 'New Cinema' : 'Edit Cinema')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
              TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}

