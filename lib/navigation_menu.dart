import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:book_store/features/screens/signup/register_screen.dart';
import 'package:book_store/features/shop/screens/home/home_screen.dart';
import 'package:book_store/features/shop/screens/home/reply.dart';
import 'package:book_store/features/shop/screens/home/request.dart';
import 'package:book_store/features/shop/screens/home/profile/user.dart';
import 'package:book_store/utils/constants/color.dart';
import 'package:book_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NavigationController>(context);
    bool dark = UHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: controller.screens[controller.selectedIndex],
      bottomNavigationBar: NavigationBar(
          elevation: 0,
          backgroundColor: dark ? UColors.primary : UColors.secondary,
          indicatorColor: dark
              ? UColors.secondary.withValues(alpha: 0.6)
              : UColors.primary.withValues(alpha: 0.6),
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: controller.updateIndex,
          destinations: [
            NavigationDestination(
                icon: Icon(
                  Iconsax.home,
                  color: UColors.accent,
                ),
                label: 'Home'),
            NavigationDestination(
              icon: Icon(
                Iconsax.repeat,
                color: UColors.accent,
              ),
              label: 'Reply',
            ),
            NavigationDestination(
                icon: Icon(
                  Iconsax.send,
                  color: UColors.accent,
                ),
                label: 'Request'),
            NavigationDestination(
              icon: Icon(
                Iconsax.user,
                color: UColors.accent,
              ),
              label: 'Profile',
            ),
          ]),
    );
  }
}

class NavigationController with ChangeNotifier {
  int selectedIndex = 0;
  final List<Widget> screens = [
    HomeScreen(),
    ReplyBookScreen(),
    RequestBookScreen(),
    UserScreen(),
  ];
  void updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
