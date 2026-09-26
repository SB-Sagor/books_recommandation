import 'dart:async';
import 'package:book_store/controller/home_helper.dart';
import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:book_store/services/book_service.dart';
import 'package:book_store/utils/constants/color.dart';
import 'package:book_store/utils/helpers/helper_functions.dart';
import 'package:book_store/widgets/book_card.dart';
import 'package:flutter/material.dart';

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
        title: Text("Book Recommended",
            style: TextStyle(
                color: dark ? UColors.dark : UColors.light,
                fontWeight: FontWeight.bold)),
        backgroundColor: dark ? UColors.primary : UColors.secondary,
      ),
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
    bool dark = UHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: TextStyle(color: dark ? UColors.secondary : UColors.primary),
        controller: searchController,
        decoration: InputDecoration(
          labelText: "Search Books",
          labelStyle: TextStyle(color: dark ? UColors.accent : UColors.accent),
          hintText: "Enter book name...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
        ),
      ),
    );
  }

  Widget _buildCategoryView() {
    bool dark = UHelperFunctions.isDarkMode(context);
    return ListView(
      children: cachedCategories.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(entry.key,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dark ? UColors.secondary : UColors.primary)),
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
    bool dark = UHelperFunctions.isDarkMode(context);
    if (recommendedBooks.isEmpty) {
      return Center(
          child: Text(
        "No recommendations found",
        style: TextStyle(color: dark ? UColors.primary : UColors.secondary),
      ));
    }
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
}
