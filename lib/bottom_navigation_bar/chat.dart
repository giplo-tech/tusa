import 'package:flutter/material.dart';

import '../color.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Text(
          'This is chat page',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.normal,
            color: AppColors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
