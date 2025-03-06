import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'city_and_district.dart';

class NicknameAndAvatarPage extends StatefulWidget {
  @override
  _NicknameAndAvatarPageState createState() => _NicknameAndAvatarPageState();
}

class _NicknameAndAvatarPageState extends State<NicknameAndAvatarPage> {
  final TextEditingController _nicknameController = TextEditingController();
  File? _avatar;
  bool _isLoading = false;

  // Метод для выбора аватарки из галереи
  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  // Метод для сохранения данных в Supabase
  Future<void> _saveProfileData() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || _avatar == null) {
      print("Никнейм или аватарка не введены");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final storage = Supabase.instance.client.storage;
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      print("Ошибка: пользователь не авторизован");
      return;
    }

    final userId = user.id;
    final avatarPath = 'avatars/${userId}.png'; // Путь к файлу в корзине

    try {
      // Загружаем аватарку в корзину 'avatars'
      final response = await storage.from('avatars').upload(avatarPath, _avatar!);

      if (response.error != null) {
        print("Ошибка при загрузке аватарки: ${response.error!.message}");
        return;
      }

      // Получаем публичную ссылку на аватарку
      final avatarUrlResponse = await storage.from('avatars').getPublicUrl(avatarPath);
      final avatarUrl = avatarUrlResponse.data;

      // Сохраняем данные профиля в Supabase
      final responseProfile = await Supabase.instance.client.from('user_profiles').upsert({
        'id': userId,
        'nickname': nickname,
        'avatar_url': avatarUrl,
      }).select().single();

      if (responseProfile.error != null) {
        print("Ошибка при сохранении данных профиля: ${responseProfile.error!.message}");
      } else {
        print("Данные профиля успешно сохранены");
        // Переход на следующую страницу
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CityAndDistrictPage()),
        );
      }
    } catch (e) {
      print("Ошибка: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Введите Никнейм и Аватарку")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Никнейм',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                child: _avatar == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfileData,
              child: _isLoading ? CircularProgressIndicator() : Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on PostgrestMap {
  get error => null;
}

extension on String {
  get error => null;

   get data => null;
}