import 'package:flutter/material.dart';
import 'package:podpole/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:podpole/bottom_navigation_bar/home.dart';
import 'package:podpole/bottom_navigation_bar/profile.dart';
import 'package:podpole/pages/login_page.dart';
import 'package:podpole/pages/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        // loading…
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return MyBottomNavBar();
        } else {
          return LoginPage();
        }
      },
    );
  }
}