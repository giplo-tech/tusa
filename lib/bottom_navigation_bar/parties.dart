import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podpole/components/widget001.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../color.dart';
import '../components/class_party.dart';
import '../components/party_storage.dart';
import '../pages/create_party.dart';

class PartiesPage extends StatefulWidget {
  const PartiesPage({super.key});

  @override
  _PartiesPageState createState() => _PartiesPageState();
}

class _PartiesPageState extends State<PartiesPage> {
  List<Party> parties = [];

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    final prefs = await SharedPreferences.getInstance();
    final String? partiesJson = prefs.getString('parties');
    if (partiesJson != null) {
      final List<dynamic> decoded = jsonDecode(partiesJson);
      setState(() {
        parties = decoded.map((item) => Party.fromJson(item)).toList();
      });
    }
  }

  // Сохранение мероприятий
  Future<void> _saveParties() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(parties.map((party) => party.toJson()).toList());
    await prefs.setString('parties', encoded);
  }

  // Добавление нового мероприятия
  void _addParty(Party newParty) {
    setState(() {
      parties.add(newParty);
    });
    _saveParties();
  }

  // Метод для удаления мероприятия
  void _deleteParty(int index) async {
    setState(() {
      parties.removeAt(index); // Удаляем мероприятие из списка
    });
    await PartyStorage.saveParties(parties); // Сохраняем обновлённый список
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // стрелка назад (выкл)
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TUS'Э",
              style: TextStyle(
                fontFamily: 'Unbounded',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary_b,
              ),
            ),
            Row(
              children: [
                // Первая кнопка (поиск)
                _buildIconButton('assets/icons/search.svg', AppColors.black_l, AppColors.white, () {
                  // Действие для поиска
                }),
                const SizedBox(width: 8),

                // Вторая кнопка (уведомления)
                _buildIconButton('assets/icons/notification.svg', AppColors.black_l, AppColors.white, () {
                  // Действие для уведомлений
                }),
                const SizedBox(width: 8),

                // Третья кнопка (добавить)
                _buildIconButton('assets/icons/add.svg', AppColors.white, AppColors.black, () async {
                  final newParty = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePartyPage()),
                  );

                  if (newParty != null) {
                    setState(() {
                      parties.add(newParty);
                    });
                    _saveParties();
                  }
                }),
              ],
            ),
          ],
        ),
      ),
      body: parties.isEmpty
          ? const Center(
        child: Text(
          "Нет мероприятий",
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parties.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(parties[index].toString()), // Уникальный ключ для каждого элемента
            direction: DismissDirection.endToStart, // Смахивание только справа налево
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.black, // Цвет фона при смахивании
              child: const Icon(
                Icons.delete,
                color: AppColors.primary,
              ),
            ),
            onDismissed: (direction) {
              _deleteParty(index); // Удаляем мероприятие
            },
            child: Column(
              children: [
                Widget001(
                  party: parties[index], // Передаём мероприятие
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

// Метод для создания кнопки с иконкой
  Widget _buildIconButton(String assetPath, Color backgroundColor, Color iconColor, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            color: iconColor, // Цвет иконки
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}