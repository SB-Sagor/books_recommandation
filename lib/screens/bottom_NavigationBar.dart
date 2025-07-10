import 'package:book_store/screens/home_screen.dart';
import 'package:book_store/screens/reply_screen.dart';
import 'package:book_store/screens/request_screen.dart';
import 'package:book_store/screens/upload_book_screen.dart';
import 'package:book_store/screens/uploaded_books_screen.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavigationbar extends StatefulWidget {
  BottomNavigationbar({super.key});

  @override
  State<BottomNavigationbar> createState() => _BottomNavigationbarState();
}

class _BottomNavigationbarState extends State<BottomNavigationbar> {
  int _current_index = 0;

  void _navigatebottombar(int index) {
    setState(() {
      _current_index = index;
    });
  }

  final List<Widget> _screens = [
    HomeScreen(),
    UploadedBooksScreen(),
    ReplyScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_current_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current_index,
        onTap: _navigatebottombar,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.card,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_rounded),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload_rounded),
            label: 'Reply',
          ),
        ],
      ),
    );
  }
}
