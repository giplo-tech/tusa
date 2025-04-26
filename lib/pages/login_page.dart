import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podpole/auth/auth_service.dart';
import 'package:podpole/pages/register_page.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../color.dart';
import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Голубой контейнер с гифкой (без боковых отступов)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Container(
                width: double.infinity,
                height: 180,
                color: AppColors.primary_b,
                child: Center(
                  child: Image.asset(
                    'lib/images/gif_eyes.gif',
                    width: 166,
                    height: 49,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Вход',
                      style: TextStyle(
                        fontFamily: 'Unbounded',
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 150),
                    _buildLoginButton(),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      child: const Text(
                        'Ещё нет аккаунта? Создать аккаунт',
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Styrene',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Электронная почта',
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontWeight: FontWeight.w300,
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: _emailController,
          hintText: "Электронная почта",
          obscureText: false,
          prefixIcon: SvgPicture.asset('assets/icons/sms_l.svg'),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Пароль',
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontWeight: FontWeight.w300,
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: _passwordController,
          hintText: "Введите пароль",
          obscureText: true,
          prefixIcon: SvgPicture.asset('assets/icons/key.svg'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SlideAction(
      height: 70,
      borderRadius: 100,
      elevation: 0,
      innerColor: AppColors.white,
      outerColor: AppColors.black_l,
      sliderButtonIcon: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.black,
      ),
      text: 'Войти',
      textStyle: const TextStyle(
        fontSize: 14,
        fontFamily: 'Unbounded',
        fontWeight: FontWeight.w100,
        color: AppColors.white,
      ),
      sliderRotate: true,
      onSubmit: login,
    );
  }
}