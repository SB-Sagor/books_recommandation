import 'dart:async';
import 'dart:convert';
import 'package:book_store/admin_panel.dart';
import 'package:book_store/forgot_password_screen.dart';
import 'package:book_store/login_screen.dart';
import 'package:book_store/upload_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> recommendedBooks = [];
  bool isLoading = false; // Loading state
  Timer? _debounce; // Timer for debouncing
  final String apiKey = 'AIzaSyD83nD_YintO_BE2RpKFZ5Qnq6qm8qTwdk';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // Debounce method
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchBooks(searchController.text);
    });
  }

  // Fetch book recommendations from Google Books API
  Future<void> searchBooks(String query) async {
    if (query.isEmpty) return; // Prevent unnecessary API calls

    setState(() {
      isLoading = true;
    });

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          recommendedBooks = responseData['items'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch book recommendations');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching books: $error");
    }
  }

  // Logout function
  // Updated logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()) // Replace with your login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Recommended",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text("Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Users"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text("Admin Panel"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UploadBookFirestore()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Books",
                hintText: "Enter book name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.0)),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: recommendedBooks.isEmpty
                ? Center(child: Text("No recommendations found"))
                : ListView.builder(
              itemCount: recommendedBooks.length,
              itemBuilder: (context, index) {
                var book = recommendedBooks[index]['volumeInfo'];
                var imageUrl = book['imageLinks'] != null
                    ? book['imageLinks']['thumbnail']
                    : null;
                return ListTile(
                  title: Text(book['title'] ?? "No Title"),
                  subtitle: Text(book['authors'] != null
                      ? book['authors'].join(', ')
                      : 'Unknown Author'),
                  leading: imageUrl != null
                      ? Image.network(imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover)
                      : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
        selectedItemColor: Colors.black,
      ),
    );
  }
}
