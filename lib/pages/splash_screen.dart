import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:podpole/pages/login_page.dart';
import '../bottom_navigation_bar/bottom_nav_bar.dart';
import '../color.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // Показываем экран 2 секунды
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyBottomNavBar()), // Если вошёл, переходим в приложение
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Если нет сессии, на логин
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding.jpg'), // Фоновая картинка
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(screenWidth, screenHeight),
                const SizedBox(height: 90),
                _buildDescription(),
                const Spacer(),
                _buildStartButton(context),
                SizedBox(height: screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double screenWidth, double screenHeight) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset(
          'assets/images/э.png',
          width: screenWidth * 0.3,
          height: screenHeight * 0.2,
        ),
        const SizedBox(height: 20),
        const Text(
          'TUSЭ',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.primary_b,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'Ну тут такое крутое ТУСЭ, оно просто шикарное, я не могла его пропустить',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Unbounded',
          fontWeight: FontWeight.w400,
          color: AppColors.primary_b,
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          _navigateToNextScreen(); // Переход в `MyBottomNavBar` или `LoginPage`
        },
        child: const Text(
          'Начать',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
