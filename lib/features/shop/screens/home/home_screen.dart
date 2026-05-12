import 'dart:async';
import 'package:book_store/controller/home_helper.dart';
import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:book_store/services/book_service.dart';
import 'package:book_store/utils/constants/color.dart';
import 'package:book_store/utils/helpers/helper_functions.dart';
import 'package:book_store/widgets/book_card.dart';
import 'package:flutter/material.dart';

// Import local files (Ensure paths are correct)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  final TextEditingController searchController = TextEditingController();

  List<dynamic> recommendedBooks = [];
  Map<String, List<dynamic>> cachedCategories = {};
  Map<String, List<dynamic>> bookCache = {};
  bool isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  void _loadInitialData() {
    final categories = [
      "Programming",
      "Science",
      "History",
      "Biography",
      "Trending"
    ];
    for (var cat in categories) {
      _preloadCategory(cat);
    }
  }

  Future<void> _preloadCategory(String category) async {
    if (cachedCategories.containsKey(category)) return;
    final books = await _bookService.fetchBooks(category);
    setState(() => cachedCategories[category] = books);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchBooks(searchController.text);
    });
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) return;
    if (bookCache.containsKey(query)) {
      setState(() => recommendedBooks = bookCache[query]!);
      return;
    }

    setState(() => isLoading = true);
    final books = await _bookService.fetchBooks(query);
    bookCache[query] = books;
    setState(() {
      recommendedBooks = books;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool dark = UHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? UColors.white : UColors.dark,
      appBar: AppBar(
        title: const Text("Book Recommended",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: UColors.primary,
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (searchController.text.isEmpty
                    ? _buildCategoryView()
                    : _buildSearchResults()),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: "Search Books",
          hintText: "Enter book name...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
        ),
      ),
    );
  }

  Widget _buildCategoryView() {
    return ListView(
      children: cachedCategories.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(entry.key,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => BookCard(
                  bookData: entry.value[index],
                  onTap: () => HomeHelper.openBook(entry.value[index], context),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults() {
    if (recommendedBooks.isEmpty)
      return const Center(child: Text("No recommendations found"));
    return ListView.builder(
      itemCount: recommendedBooks.length,
      itemBuilder: (context, index) {
        final book = recommendedBooks[index]['volumeInfo'];
        return ListTile(
          leading: book['imageLinks']?['thumbnail'] != null
              ? Image.network(book['imageLinks']['thumbnail'],
                  width: 50, fit: BoxFit.cover)
              : const Icon(Icons.book, size: 40),
          title: Text(book['title'] ?? "No Title"),
          subtitle: Text(book['authors']?.join(', ') ?? "Unknown Author"),
          onTap: () => HomeHelper.openBook(recommendedBooks[index], context),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: UColors.primary),
            child: Text("Book Store",
                style: TextStyle(color: Colors.black, fontSize: 24)),
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Users"),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Upload Books"),
              onTap: () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => HomeHelper.logout(context, LoginScreen()),
          ),
        ],
      ),
    );
  }
}
