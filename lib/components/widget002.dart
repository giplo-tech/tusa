import 'package:flutter/material.dart';
import '../color.dart';

class Widget002 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const Widget002({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0), // Отступы по краям
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: null, // Автоматически увеличивает высоту
        minLines: 1, // Минимальное количество строк
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.black_l,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: "Styrene",
            fontSize: 16,
            color: AppColors.grey,
            fontWeight: FontWeight.w100,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Отступы внутри
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.black_l),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Styrene',
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}