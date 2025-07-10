import 'dart:async';
import 'dart:convert';
import 'package:book_store/screens/request_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_store/screens/book_detail_screen.dart';
import 'package:book_store/screens/login_screen.dart';
import 'package:book_store/screens/upload_book_screen.dart';
import 'package:book_store/screens/uploaded_books_screen.dart';
import 'package:book_store/widgets/app_colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allBooks = [];
  List<dynamic> filteredBooks = [];
  bool isLoading = false;
  String selectedCategory = "Trending";
  Timer? _debounce;

  final String apiKey =
      'AIzaSyD83nD_YintO_BE2RpKFZ5Qnq6qm8qTwdk'; // Replace with your API key

  final List<String> categories = [
    "Trending",
    "Popular",
    "Horror",
    "History",
    "Science",
    "Biography"
  ];

  @override
  void initState() {
    super.initState();
    fetchBooks("trending");
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchBooks(searchController.text);
    });
  }

  Future<void> fetchBooks(String query) async {
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      setState(() {
        allBooks = data['items'] ?? [];
        filteredBooks = allBooks;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching books: $e");
      setState(() => isLoading = false);
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      fetchBooks(category);
    });
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut(); //  Supabase logout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BOOK RECOMMENDATIONS",
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '📚 Book Menu',
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: AppColors.textPrimary),
              title: Text('Upload Book',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UploadBookScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books, color: AppColors.textPrimary),
              title: Text('Uploaded Books',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UploadedBooksScreen()),
                );
              },
            ),ListTile(
              leading: Icon(Icons.read_more_rounded, color: AppColors.textPrimary),
              title: Text('Book Request',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RequestBookScreen()),
                );
              },
            ),
            Spacer(),
            Divider(color: Colors.white24),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: logout,
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search books...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // 👤 Authors
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredBooks.length.clamp(0, 10),
              itemBuilder: (context, index) {
                var book = filteredBooks[index]['volumeInfo'];
                var authorName =
                    (book['authors'] != null) ? book['authors'][0] : "Unknown";

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          authorName[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        authorName.length > 6
                            ? authorName.substring(0, 6) + "..."
                            : authorName,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🏷️ Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, index) {
                String cat = categories[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) => filterByCategory(cat),
                    selectedColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color:
                          selectedCategory == cat ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // 📚 Book List
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      var book = filteredBooks[index]['volumeInfo'];
                      var title = book['title'] ?? "No Title";
                      var authors = (book['authors'] ?? ["Unknown"]).join(', ');
                      var imageUrl = book['imageLinks']?['thumbnail'] ??
                          "https://via.placeholder.com/100";
                      var description = book['description'] ?? "No description";
                      var previewLink = book['previewLink'] ?? '';
                      var pdfUrl = filteredBooks[index]['accessInfo']?['pdf']
                              ?['downloadLink'] ??
                          '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        title: Text(title),
                        subtitle: Text(authors),
                        onTap: () {
                          if (pdfUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("No PDF available for this book")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(
                                title: title,
                                author: authors,
                                description: description,
                                imageUrl: imageUrl,
                                previewLink: previewLink,
                                pdfUrl: pdfUrl,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
