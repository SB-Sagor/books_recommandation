import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../controller/home_helper.dart';
import '../../../../../utils/constants/color.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../screens/login/login_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = UHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? UColors.light : UColors.dark,
      appBar: AppBar(
        backgroundColor: dark ? UColors.primary : UColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dark
                    ? UColors.secondary.withValues(alpha: 0.1)
                    : UColors.primary.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Iconsax.user, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Book Store User",
                    style: TextStyle(
                      color: dark ? UColors.secondary : UColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildListTile(
              icon: Iconsax.user,
              title: "Users",
              dark: dark,
              onTap: () {},
            ),
            _buildListTile(
              icon: Iconsax.document_upload,
              title: "Upload Books",
              dark: dark,
              onTap: () {},
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            _buildListTile(
              icon: Iconsax.logout,
              title: "Logout",
              dark: dark,
              color: Colors.red,
              onTap: () => HomeHelper.logout(context, LoginScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool dark,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: dark ? UColors.buttonPrimary : UColors.buttonPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: dark ? UColors.secondary : UColors.primary,
          fontSize: 16,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: UColors.primary),
      onTap: onTap,
    );
  }
}
