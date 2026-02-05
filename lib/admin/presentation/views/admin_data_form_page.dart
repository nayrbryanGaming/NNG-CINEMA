import 'package:flutter/material.dart';

class AdminDataFormPage extends StatefulWidget {
  final String? itemId;
  const AdminDataFormPage({super.key, this.itemId});

  @override
  State<AdminDataFormPage> createState() => _AdminDataFormPageState();
}

class _AdminDataFormPageState extends State<AdminDataFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  String _category = 'General';

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      // load sample
      _title.text = 'Data Item ${widget.itemId}';
      _subtitle.text = 'Subtitle ${widget.itemId}';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved (simulated)')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemId == null ? 'Add Data' : 'Edit Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _subtitle, decoration: const InputDecoration(labelText: 'Subtitle')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                initialValue: _category,
                items: ['General', 'News', 'Event'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'General'),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
