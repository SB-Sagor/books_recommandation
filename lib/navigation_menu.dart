import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:book_store/features/screens/signup/register_screen.dart';
import 'package:book_store/features/shop/screens/home/home_screen.dart';
import 'package:book_store/features/shop/screens/home/reply.dart';
import 'package:book_store/features/shop/screens/home/request.dart';
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
          backgroundColor: dark ? UColors.light : UColors.dark,
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: controller.updateIndex,
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.repeat), label: 'Reply'),
            NavigationDestination(icon: Icon(Iconsax.send), label: 'Request'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
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
    HomeScreen()
  ];
  void updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
