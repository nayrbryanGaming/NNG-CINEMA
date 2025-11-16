import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';

class EditProfileView extends StatefulWidget {
  final UserProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  String? _newProfileImagePath;
  String? _newBannerImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(text: widget.profile.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(String) onImagePicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        onImagePicked(pickedFile.path);
      });
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final profileService = sl<ProfileService>();

      bool canChangeUsername = true;
      if (_usernameController.text != widget.profile.username) {
        final now = DateTime.now();
        final lastChanged = widget.profile.usernameLastChanged;
        if (lastChanged != null && now.difference(lastChanged).inDays < 30) {
          canChangeUsername = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You can only change your username once every 30 days.')),
            );
          }
        }
      }

      if (canChangeUsername) {
        final updatedProfile = widget.profile.copyWith(
          name: _nameController.text,
          username: _usernameController.text,
          profilePictureUrl: _newProfileImagePath,
          bannerUrl: _newBannerImagePath,
          usernameLastChanged: _usernameController.text != widget.profile.username
              ? DateTime.now()
              : widget.profile.usernameLastChanged,
        );

        await profileService.saveProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          context.pop(true);
        }
      } else {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _onSave,
              tooltip: 'Save',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreviews(),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', prefixText: '@'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Username cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Username can only be changed once every 30 days.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: () => _pickImage(ImageSource.gallery, (path) => _newBannerImagePath = path),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: _buildImageProvider(_newBannerImagePath ?? widget.profile.bannerUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 40)),
            ),
          ),
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () => _pickImage(ImageSource.gallery, (path) => _newProfileImagePath = path),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _buildImageProvider(_newProfileImagePath ?? widget.profile.profilePictureUrl),
                  child: const Center(child: Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _buildImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }
}
