import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podpole/auth/auth_service.dart';
import 'package:podpole/pages/login_page.dart';
import 'package:podpole/pages/nickname_and_avatar_page.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../color.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await _authService.signUpWithEmailPassword(email, password);

      if (response.user?.id == null) {
        throw Exception('Не удалось получить ID пользователя');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NicknameAndAvatarPage(userId: response.user!.id),
        ),
      );

    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('already registered')) {
      return 'Пользователь с такой почтой уже зарегистрирован';
    } else if (error.toString().contains('weak password')) {
      return 'Пароль должен содержать минимум 6 символов';
    } else if (error.toString().contains('invalid email')) {
      return 'Некорректный формат email';
    }
    return 'Ошибка регистрации: ${error.toString()}';
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введите email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Некорректный формат email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Регистрация',
                        style: TextStyle(
                          fontFamily: 'Unbounded',
                          fontWeight: FontWeight.normal,
                          color: AppColors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 40),
                      _buildLoginButton(),
                      const SizedBox(height: 40),
                      _buildLoginLink(),
                    ],
                  ),
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
          hintText: "Введите пароль (мин. 6 символов)",
          obscureText: true,
          prefixIcon: SvgPicture.asset('assets/icons/key.svg'),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            'Подтвердите пароль',
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
          controller: _confirmPasswordController,
          hintText: "Повторите пароль",
          obscureText: true,
          prefixIcon: SvgPicture.asset('assets/icons/key.svg'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return IgnorePointer(
      ignoring: _isLoading,
      child: SlideAction(
        height: 70,
        borderRadius: 100,
        elevation: 0,
        innerColor: AppColors.white,
        outerColor: AppColors.black_l,
        sliderButtonIcon: _isLoading
            ? const CircularProgressIndicator(color: AppColors.black)
            : const Icon(Icons.arrow_forward_ios, color: AppColors.black),
        text: _isLoading ? 'Регистрация...' : 'Создать аккаунт',
        textStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'Unbounded',
          fontWeight: FontWeight.w100,
          color: AppColors.white,
        ),
        sliderRotate: true,
        onSubmit: _signUp,
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      ),
      child: Text(
        'Уже есть аккаунт? Войдите',
        style: TextStyle(
          color: _isLoading ? Colors.grey : AppColors.white,
        ),
      ),
    );
  }
}