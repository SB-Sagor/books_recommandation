import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:book_store/features/screens/signup/register_screen.dart';
import 'package:book_store/features/shop/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NevigationMenu extends StatelessWidget {
  const NevigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NavigationController>(context);
    return Scaffold(
      body: controller.screens[controller.selectedIndex],
      bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: controller.updateIndex,
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.shop), label: 'Shop'),
            NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ]),
    );
  }
}

class NavigationController with ChangeNotifier {
  int selectedIndex = 0;
  final List<Widget> screens = [
    HomeScreen(),
    LoginScreen(),
    RegisterScreen(),
    HomeScreen()
  ];
  void updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
