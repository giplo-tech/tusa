import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podpole/color.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../components/class_party.dart';

class PartyDetailsPage extends StatelessWidget {
  final Party party;

  const PartyDetailsPage({Key? key, required this.party}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: screenHeight * 0.12), // Отступ под кнопку
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фотография (на всю ширину, высота 300)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.asset(
                    'assets/images/party.png',
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Text(
                        party.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Unbounded',
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Описание
                      Text(
                        party.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Styrene',
                          fontWeight: FontWeight.w300,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Информация о мероприятии
                      Column(
                        children: [
                          _buildInfoRow('Дата', party.date),
                          _buildInfoRow('Время', party.time),
                          _buildInfoRow('Место', party.place),
                          _buildInfoRow('Адрес', party.address),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Фиксированные кнопки (назад + поделиться)
          Positioned(
            top: 40,
            left: 16,
            child: _buildCircleButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _buildCircleButton(
              icon: Icons.share,
              onPressed: () {},
            ),
          ),

          // Фиксированная кнопка "Присоединиться"
          Positioned(
            bottom: screenHeight * 0.05, // Поднимаем примерно на 10% высоты экрана
            left: 16,
            right: 16,
            child: SlideAction(
              height: 70,
              borderRadius: 100,
              elevation: 0,
              innerColor: AppColors.white,
              outerColor: AppColors.black_l,
              sliderButtonIcon: const Icon(Icons.arrow_forward_ios, color: AppColors.black),
              text: 'Принять',
              textStyle: const TextStyle(
                fontSize: 14,
                fontFamily: 'Unbounded',
                fontWeight: FontWeight.w100,
                color: AppColors.white,
              ),
              sliderRotate: true,
              onSubmit: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для строки информации
  Widget _buildInfoRow(String label, String value) {
    String truncatedValue = value.length > 40 ? '${value.substring(0, 37)}...' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 6),
          SizedBox(
            width: 100, // Фиксированная ширина для label
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Styrene',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              overflow: TextOverflow.ellipsis, // Если текст длинный, он не выйдет за границы
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              truncatedValue,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Styrene',
                fontWeight: FontWeight.w200,
                color: AppColors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }


  // Круглая кнопка (назад/поделиться)
  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
