import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color.dart';
import 'package:podpole/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  String? nickname;
  File? avatar;
  bool _isLoading = true; // Флаг загрузки

  // Загрузка данных профиля
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Загружаем никнейм и путь к аватарке из SharedPreferences
    nickname = prefs.getString('nickname');
    String? avatarPath = prefs.getString('avatar');
    if (avatarPath != null) {
      avatar = File(avatarPath); // Загружаем аватарку из пути
    }

    setState(() {
      _isLoading = false; // Когда загрузка завершена
    });
  }

  // Функция выхода из профиля
  void logout() async {
    await authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Загружаем данные при инициализации
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text('TUSЭ'),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Показываем индикатор загрузки
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: avatar != null ? FileImage(avatar!) : null,
              child: avatar == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            SizedBox(height: 20),
            Text(
              nickname ?? 'Нет имени',
              style: TextStyle(
                fontFamily: 'Unbounded',
                fontWeight: FontWeight.normal,
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}