import 'package:flutter/material.dart';
import 'movie_repository.dart';
import 'movie_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class MovieFormPage extends StatefulWidget {
  final String? movieId;
  const MovieFormPage({Key? key, this.movieId}) : super(key: key);

  @override
  State<MovieFormPage> createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _synopsis = TextEditingController();
  final _genres = TextEditingController();
  final _duration = TextEditingController();
  final _rating = TextEditingController();
  bool _loading = false;
  final MovieRepository _repo = MovieRepository();
  File? _pickedImage;
  String? _posterUrl;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.movieId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final m = await _repo.getById(widget.movieId!);
      _title.text = m.title;
      _synopsis.text = m.synopsis;
      _genres.text = m.genres.join(', ');
      _duration.text = m.durationMinutes.toString();
      _rating.text = m.rating.toString();
      _posterUrl = m.posterUrl;
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pic = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (pic == null) return;
    setState(() => _pickedImage = File(pic.path));
  }

  Future<String?> _uploadPoster(File file) async {
    // Basic validation: reject large files > 5MB
    final maxBytes = 5 * 1024 * 1024;
    if (await file.length() > maxBytes) {
      throw Exception('Selected image is larger than 5MB');
    }

    final name = 'posters/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = FirebaseStorage.instance.ref().child(name);
    final uploadTask = ref.putFile(file);

    // Monitor progress
    uploadTask.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      }
    });

    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await ref.getDownloadURL();
    setState(() {
      _uploadProgress = 0.0;
    });
    return url;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_pickedImage != null) {
        _posterUrl = await _uploadPoster(_pickedImage!);
      }
      final m = MovieModel(
        id: widget.movieId ?? '',
        title: _title.text.trim(),
        synopsis: _synopsis.text.trim(),
        genres: _genres.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        durationMinutes: int.tryParse(_duration.text) ?? 0,
        rating: double.tryParse(_rating.text) ?? 0.0,
        trailerUrl: null,
        posterUrl: _posterUrl,
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.movieId == null) {
        await _repo.create(m);
      } else {
        await _repo.update(m);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movieId == null ? 'New Movie' : 'Edit Movie')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    TextFormField(controller: _synopsis, decoration: const InputDecoration(labelText: 'Synopsis'), maxLines: 4),
                    TextFormField(controller: _genres, decoration: const InputDecoration(labelText: 'Genres (comma separated)')),
                    TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (minutes)'), keyboardType: TextInputType.number),
                    TextFormField(controller: _rating, decoration: const InputDecoration(labelText: 'Rating'), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    if (_posterUrl != null) Image.network(_posterUrl!, height: 120),
                    if (_pickedImage != null) Image.file(_pickedImage!, height: 120),
                    if (_uploadProgress > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(value: _uploadProgress),
                      ),
                    TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Pick Poster')),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _save, child: const Text('Save')),
                  ],
                ),
              ),
            ),
    );
  }
}
