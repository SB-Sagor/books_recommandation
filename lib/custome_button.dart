import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

Widget customButton(String buttonText, onPressed) {
  return SizedBox(
    width: 1.sw, // Use ScreenUtil here
    height: 56.h, // Use ScreenUtil here
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
            color: Colors.white, fontSize: 18.sp), // Use ScreenUtil here
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deep_orange,
        elevation: 3,
      ),
    ),
  );
}
