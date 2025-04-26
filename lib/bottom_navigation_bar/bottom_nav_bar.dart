import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podpole/bottom_navigation_bar/parties.dart';
import 'package:podpole/bottom_navigation_bar/profile.dart';
import 'package:podpole/color.dart';

import 'chat.dart';
import 'home.dart';

class MyBottomNavBar extends StatefulWidget {
  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PartiesPage(),
    ChatPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex], // Текущая страница

          /// Floating Navigation Bar
          Positioned(
            bottom: 20, // Поднимаем навбар
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.black_l,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('assets/icons/map.svg', 0),
                  _buildNavItem('assets/icons/story.svg', 1),
                  _buildNavItem('assets/icons/sms.svg', 2),
                  _buildNavItem('assets/icons/user.svg', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Создаём элемент навбара (без изменения формы)
  Widget _buildNavItem(String iconPath, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: SvgPicture.asset(
        iconPath,
        height: 30,
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.white : AppColors.grey, // Просто меняем цвет
          BlendMode.srcIn,
        ),
      ),
    );
  }
}