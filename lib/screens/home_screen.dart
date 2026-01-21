import 'dart:async';
import 'dart:convert';
import 'package:book_store/screens/login_screen.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Map<String, List<dynamic>> cachedCategories = {};
  Map<String, List<dynamic>> bookCache = {};
  List<dynamic> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);

    preloadCategory("Programming");
    preloadCategory("Science");
    preloadCategory("History");
    preloadCategory("Biography");
    preloadCategory("Trending");
  }

  Future<void> preloadCategory(String category) async {
    if (cachedCategories.containsKey(category)) return; // cache check

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$category&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final books = responseData['items'] ?? [];
      setState(() {
        cachedCategories[category] = books;
      });
    }
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
    if (query.isEmpty) return;

    // ✅ Check cache first
    if (bookCache.containsKey(query)) {
      setState(() {
        recommendedBooks = bookCache[query]!;
      });
      return;
    }

    setState(() => isLoading = true);

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final books = responseData['items'] ?? [];

        // ✅ Save to cache
        bookCache[query] = books;

        setState(() {
          recommendedBooks = books;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() => isLoading = false);
      print("Error fetching books: $error");
    }
  }

  Future<void> _openBook(Map<String, dynamic> book) async {
    // লিঙ্কগুলো পুরো item থেকে নিতে হবে
    String? previewLink = book['volumeInfo']?['previewLink'];
    String? canonicalLink = book['volumeInfo']?['canonicalVolumeLink'];
    String? infoLink = book['infoLink']; // এটা volumeInfo নয়, item level এ থাকে

    final link = previewLink ?? canonicalLink ?? infoLink;

    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No source available for this book")),
      );
      return;
    }

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open book link")),
      );
    }
  }

  // Logout function
  // Updated logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                LoginScreen()) // Replace with your login screen
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Recommended",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text("Book Store",
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Users"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text("Uoload Books"),
              onTap: () {},
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
                  child: searchController.text.isEmpty
                      ? _buildCategoryView() // ✅ Default category horizontal scroll
                      : _buildSearchResults(), // ✅ Search result listview
                )
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

  Widget _buildCategoryView() {
    return ListView(
      children: cachedCategories.entries.map((entry) {
        final category = entry.key;
        final books = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(category,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  var book = books[index]['volumeInfo'];
                  var imageUrl = book['imageLinks']?['thumbnail'];

                  return GestureDetector(
                    onTap: () =>
                        _openBook(books[index]), // ✅ এখানে books ব্যবহার করো
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: imageUrl != null
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Icon(Icons.book,
                                    size: 60, color: Colors.grey),
                          ),
                          Text(book['title'] ?? "No Title",
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (recommendedBooks.isEmpty) {
      return Center(child: Text("No recommendations found"));
    }

    return ListView.builder(
      itemCount: recommendedBooks.length,
      itemBuilder: (context, index) {
        var book = recommendedBooks[index]['volumeInfo'];
        var imageUrl = book['imageLinks']?['thumbnail'];
        var infoLink = book['infoLink'];

        return ListTile(
          leading: imageUrl != null
              ? Image.network(imageUrl,
                  width: 50, height: 50, fit: BoxFit.cover)
              : Icon(Icons.book, size: 40, color: Colors.grey),
          title: Text(book['title'] ?? "No Title"),
          subtitle: Text(book['authors']?.join(', ') ?? "Unknown Author"),
          onTap: () => _openBook(recommendedBooks[index]),
        );
      },
    );
  }
}
