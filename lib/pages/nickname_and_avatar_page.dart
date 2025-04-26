import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:podpole/bottom_navigation_bar/bottom_nav_bar.dart';
import 'dart:io';

import 'city_and_district.dart';

class NicknameAndAvatarPage extends StatefulWidget {
  final String userId;
  const NicknameAndAvatarPage({required this.userId, super.key});

  @override
  State<NicknameAndAvatarPage> createState() => _NicknameAndAvatarPageState();
}

class _NicknameAndAvatarPageState extends State<NicknameAndAvatarPage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _avatarFile;
  bool _isLoading = false;
  bool _isUploading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() => _avatarFile = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка выбора изображения: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Проверка уникальности никнейма
      final usernameExists = await _supabase
          .from('user_info')
          .select('username')
          .eq('username', _usernameController.text.trim())
          .maybeSingle();

      if (usernameExists != null) {
        throw Exception('Этот никнейм уже занят');
      }

      String? avatarUrl;

      if (_avatarFile != null) {
        setState(() => _isUploading = true);
        final fileExt = _avatarFile!.path.split('.').last;
        final fileName = 'avatars/${widget.userId}_avatar.$fileExt';

        await _supabase.storage
            .from('avatars')
            .upload(
          fileName,
          _avatarFile!,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$fileExt',
          ),
        );

        avatarUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Сохраняем в user_info
      final response = await _supabase.from('user_info').upsert({
        'id': widget.userId,
        'username': _usernameController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) {
        throw Exception('Не удалось сохранить профиль');
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LocationSelectionPage(userId: widget.userId)),
            (route) => false,
      );
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка базы данных: ${e.message}')),
      );
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки изображения: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
      debugPrint('Ошибка сохранения профиля: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите никнейм';
    }
    if (value.length < 3) {
      return 'Никнейм должен быть не менее 3 символов';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Только буквы, цифры и подчёркивания';
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    if (value.length < 2) {
      return 'Имя должно быть не менее 2 символов';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шаг 1: Профиль')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Настройте ваш профиль',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : null,
                        child: _avatarFile == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo, size: 30),
                            const SizedBox(height: 5),
                            Text(
                              'Добавить фото',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Ваше имя*',
                  border: OutlineInputBorder(),
                  hintText: 'Как вас будут называть',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateDisplayName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Никнейм*',
                  border: OutlineInputBorder(),
                  hintText: 'Уникальное имя пользователя',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: _validateUsername,
              ),
              const SizedBox(height: 10),
              const Text(
                'Никнейм может содержать только буквы, цифры и подчёркивания',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Сохранить и продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
}