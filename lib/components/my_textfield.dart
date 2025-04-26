import 'package:flutter/material.dart';
import '../color.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon; // Только иконка

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: "Unbounded",
          fontSize: 12,
          color: AppColors.white,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.black_l,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: "Unbounded",
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: prefixIcon,
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.black_l),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
