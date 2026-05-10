import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:cafescope_sby/app/router/app_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto redirect setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        context.goNamed(AppRoute.home.name);
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 65,
              backgroundColor: Color(0xFFFAF7F2),
              child: Icon(
                Icons.coffee_rounded,
                size: 80,
                color: Color(0xFF5D4037),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'CafeScope',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            Text(
              'SURABAYA',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}