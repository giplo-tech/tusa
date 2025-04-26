import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:podpole/bottom_navigation_bar/bottom_nav_bar.dart';

import '../data/location_data.dart';

class LocationSelectionPage extends StatefulWidget {
  final String userId;
  const LocationSelectionPage({required this.userId, super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedMetro;

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Сначала получаем текущий username
      final currentData = await _supabase
          .from('user_info')
          .select('username')
          .eq('id', widget.userId)
          .single();

      final updates = {
        'id': widget.userId,
        'username': currentData['username'], // Добавляем существующий username
        'city': _selectedCity,
        'district': _selectedDistrict,
        'metro_station': _selectedMetro,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from('user_info')
          .upsert(updates)
          .select()
          .single();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MyBottomNavBar()),
            (route) => false,
      );
    } catch (e) {
      // Обработка ошибок
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шаг 2: Местоположение')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Укажите ваше местоположение',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Выбор города
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'Город*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: cities.map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                )).toList(),
                onChanged: (city) => setState(() {
                  _selectedCity = city;
                  _selectedDistrict = null;
                  _selectedMetro = null;
                }),
                validator: (value) => value == null ? 'Выберите город' : null,
              ),

              const SizedBox(height: 20),

              // Выбор района
              if (_selectedCity != null && districtsByCity.containsKey(_selectedCity))
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'Район',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                  items: districtsByCity[_selectedCity]!.map((district) => DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  )).toList(),
                  onChanged: (district) => setState(() => _selectedDistrict = district),
                ),

              const SizedBox(height: 20),

              // Выбор метро
              if (_selectedCity != null && metroByCity.containsKey(_selectedCity))
                DropdownButtonFormField<String>(
                  value: _selectedMetro,
                  decoration: const InputDecoration(
                    labelText: 'Станция метро',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_subway),
                  ),
                  items: metroByCity[_selectedCity]!.map((metro) => DropdownMenuItem(
                    value: metro,
                    child: Text(metro),
                  )).toList(),
                  onChanged: (metro) => setState(() => _selectedMetro = metro),
                ),

              const SizedBox(height: 30),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLocation,
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
}