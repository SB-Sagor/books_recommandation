import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'package:book_store/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vmuumzdmtiicgbvbilhl.supabase.co', //  Corrected
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtdXVtemRtdGlpY2didmJpbGhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2Mjk3NTQsImV4cCI6MjA2NzIwNTc1NH0.OY9izH4h1LLCC3UFPbvWC6stuBSTM4HsFIauwsEDPIQ',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Book Store',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: AppColors.textPrimary),
              bodyMedium: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
