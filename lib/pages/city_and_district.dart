import 'package:flutter/material.dart';
import 'package:podpole/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CityAndDistrictPage extends StatefulWidget {
  @override
  _CityAndDistrictPageState createState() => _CityAndDistrictPageState();
}

class _CityAndDistrictPageState extends State<CityAndDistrictPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  bool _isLoading = false;

  // Метод для сохранения города и района в Supabase
  Future<void> _saveCityAndDistrict() async {
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();

    if (city.isEmpty || district.isEmpty) {
      print("Город или район не введены");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("Ошибка: пользователь не авторизован");
      return;
    }

    final userId = user.id;

    try {
      // Сохранение города и района в таблице Supabase
      final response = await Supabase.instance.client.from('user_profiles').upsert({
        'id': userId,
        'city': city,
        'district': district,
      }).select().single();

      if (response.error != null) {
        print("Ошибка при сохранении данных: ${response.error!.message}");
      } else {
        print("Город и район успешно сохранены");

        // Переход на страницу профиля
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyBottomNavBar()),
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
      appBar: AppBar(title: Text("Выберите Город и Район")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Город',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _districtController,
              decoration: InputDecoration(
                labelText: 'Район',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCityAndDistrict,
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