import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podpole/pages/login_page.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../auth/auth_service.dart';
import '../color.dart';
import '../components/my_textfield.dart';
import 'nickname_and_avatar_page.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password do not match'),));
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NicknameAndAvatarPage(), // Замените на нужный экран
        ),
      );

    }
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 20), // Divider between fields
                _buildPasswordField(),
                const SizedBox(height: 20), // Divider between fields
                _buildConfirmPasswordField(),
                const SizedBox(height: 70),
                _buildLoginButton(),
                const SizedBox(height: 40),
                GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        )
                    ),
                    child: const Text(
                      'Уже есть аккаунт? Войдите',
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Widget with Logo and Title
  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'lib/images/gif_eyes.gif',
          width: 166,
          height: 49,
        ),
        const SizedBox(height: 30),
        const Text(
          'Регистрация',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.normal,
            color: AppColors.white,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  // Email Field Widget
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Электронная почта',
            style: TextStyle(
              fontFamily: 'Styrene',
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: _emailController,
          hintText: "Введите электронную почту",
          obscureText: false,
          prefixIcon: SvgPicture.asset('assets/icons/sms_l.svg'), // Added icon from assets
        ),
      ],
    );
  }

  // Password Field Widget
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Пароль',
            style: TextStyle(
              fontFamily: 'Styrene',
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: _passwordController,
          hintText: "Введите пароль",
          obscureText: true, // Password should be obscured
          prefixIcon: SvgPicture.asset('assets/icons/key.svg'), // Added icon from assets
        ),
      ],
    );
  }

  // Confirm Password Field Widget
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Подтвердите пароль',
            style: TextStyle(
              fontFamily: 'Styrene',
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: _confirmPasswordController,
          hintText: "Повторите пароль",
          obscureText: true, // Password should be obscured
          prefixIcon: SvgPicture.asset('assets/icons/key.svg'), // Added icon from assets
        ),
      ],
    );
  }

  // Login Button Widget with Slide Action
  Widget _buildLoginButton() {
    return SlideAction(
      height: 70,
      borderRadius: 100,
      elevation: 0,
      innerColor: AppColors.white,
      outerColor: AppColors.black_l,
      sliderButtonIcon: const Icon(Icons.arrow_forward_ios, color: AppColors.black),
      text: 'Создать аккаунт',
      textStyle: const TextStyle(
        fontSize: 14,
        fontFamily: 'Unbounded',
        fontWeight: FontWeight.w100,
        color: AppColors.white,
      ),
      sliderRotate: true,
      onSubmit: signUp,
    );
  }
}
