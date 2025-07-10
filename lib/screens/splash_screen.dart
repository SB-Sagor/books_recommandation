import 'dart:async';
import 'package:book_store/screens/login_screen.dart';
import 'package:book_store/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {print("⏩ Navigating to AuthCheck...");

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthCheck()),

      );
    });
  }


  @override
  Widget build(BuildContext context) {
    print("✅ SplashScreen loaded");

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Book-Store",
              style: TextStyle(
                color: Colors.white,
                fontSize: 44.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
