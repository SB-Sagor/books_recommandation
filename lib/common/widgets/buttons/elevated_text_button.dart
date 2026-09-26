import 'package:book_store/utils/constants/color.dart';
import 'package:book_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class UElevatedTextButton extends StatelessWidget {
  const UElevatedTextButton({
    super.key,
    required this.onPressed,
    required this.text,
  });
  final VoidCallback onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    bool dark = UHelperFunctions.isDarkMode(context);
    return TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: dark ? UColors.dark : UColors.light),
        ));
  }
}
