import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Импорт для работы с SVG
import 'package:image_picker/image_picker.dart';
import '../color.dart';
import '../components/class_party.dart';
import '../components/my_textfield.dart';
import '../components/party_storage.dart';
import '../components/widget002.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart'; // Для сохранения файла

class CreatePartyPage extends StatefulWidget {
  @override
  _CreatePartyPageState createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();


  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      String formattedDate = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      dateController.text = formattedDate;
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String formattedTime = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      timeController.text = formattedTime;
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'января';
      case 2:
        return 'февраля';
      case 3:
        return 'марта';
      case 4:
        return 'апреля';
      case 5:
        return 'мая';
      case 6:
        return 'июня';
      case 7:
        return 'июля';
      case 8:
        return 'августа';
      case 9:
        return 'сентября';
      case 10:
        return 'октября';
      case 11:
        return 'ноября';
      case 12:
        return 'декабря';
      default:
        return '';
    }
  }

  void _saveParty() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        placeController.text.isEmpty ||
        addressController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      return; // Если не все поля заполнены, не сохраняем
    }

    // Создаём объект мероприятия
    Party newParty = Party(
      title: titleController.text,
      description: descriptionController.text,
      place: placeController.text,
      address: addressController.text,
      date: dateController.text,
      time: timeController.text,
    );

    // Загружаем текущий список мероприятий, добавляем новое и сохраняем
    List<Party> parties = await PartyStorage.loadParties();
    parties.add(newParty);
    await PartyStorage.saveParties(parties);

    // Закрываем страницу и передаём созданное мероприятие обратно
    Navigator.pop(context, newParty);
  }

  void _onPressed() {
    Navigator.pop(context); // Закрыть текущую страницу
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Добавить мероприятие',
              style: TextStyle(
                fontFamily: 'Unbounded',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.black_l,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/close_circle.svg',
                    color: AppColors.white,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Название',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              Widget002(
                controller: titleController,
                hintText: 'Название мероприятия',
                obscureText: false,
              ),

              const SizedBox(height: 24,),

              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Описание',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              Widget002(
                controller: descriptionController,
                hintText: 'Описание... Например: девки, мы долго думали с Артемом, надумали собратьсяна тусовку',
                obscureText: false,
              ),

              const SizedBox(height: 24,),

              // Place
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Место проведения',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              Widget002(
                controller: placeController,
                hintText: 'Место проведения мероприятия',
                obscureText: false,
              ),

              const SizedBox(height: 24,),

              // Address
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Адрес места',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              Widget002(
                controller: addressController,
                hintText: 'Адрес места события',
                obscureText: false,
              ),

              const SizedBox(height: 24,),

              // Date
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Дата события',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: Widget002(
                    controller: dateController,
                    hintText: 'Дата начала проведения события',
                    obscureText: false,
                  ),
                ),
              ),

              const SizedBox(height: 24,),

              // Time
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Время события',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: Widget002(
                    controller: timeController,
                    hintText: 'Время начала проведения события',
                    obscureText: false,
                  ),
                ),
              ),

              const SizedBox(height: 24,),

              // Кнопка "Сохранить"
              SizedBox(
                height: 56, // Высота кнопки
                child: FractionallySizedBox(
                  widthFactor: 1, // Занимает всю доступную ширину
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white, // Светлая кнопка
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _saveParty,
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Unbounded',
                        fontWeight: FontWeight.w500,
                        color: AppColors.black, // Цвет текста
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}