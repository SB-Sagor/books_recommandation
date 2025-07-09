import 'package:book_store/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class UploadedBooksScreen extends StatefulWidget {
  @override
  _UploadedBooksScreenState createState() => _UploadedBooksScreenState();
}

class _UploadedBooksScreenState extends State<UploadedBooksScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _booksFuture;
  bool isOpeningPdf = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _booksFuture = fetchBooks();
  }

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    final response = await supabase
        .from('books')
        .select('*')
        .order('created_at', ascending: false)
        .execute();

    final data = response.data;

    if (data == null || data is! List) {
      print("❌ Failed to fetch books or unexpected format.");
      return [];
    }

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _booksFuture = fetchBooks();
    });
  }

  Future<void> _openPdf(String url) async {
    if (isOpeningPdf) return;
    setState(() => isOpeningPdf = true);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode
                .inAppBrowserView); // or LaunchMode.externalApplication
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open PDF")),
        );
      }
    } catch (e) {
      print("❌ Error opening PDF: $e");
    } finally {
      setState(() => isOpeningPdf = false);
    }
  }

  Future<void> _downloadPdf(String url, String fileName) async {
    if (isDownloading || url.isEmpty) return;
    setState(() => isDownloading = true);

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/$fileName';

      await Dio().download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Downloaded to $filePath")),
      );
    } catch (e) {
      print("❌ Download failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed")),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title:
            Text("📚 Uploaded Books", style: TextStyle(color: AppColors.card)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Something went wrong!",
                    style: TextStyle(color: Colors.white)));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
                child: Text("No books uploaded yet.",
                    style: TextStyle(color: Colors.white70)));
          }

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (var book in books) {
            final category = book['category'] ?? 'Uncategorized';
            grouped.putIfAbsent(category, () => []).add(book);
          }

          return RefreshIndicator(
            onRefresh: _refreshBooks,
            child: ListView(
              padding: EdgeInsets.only(bottom: 24),
              children: grouped.entries.map((entry) {
                final category = entry.key;
                final booksInCategory = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.tealAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 270,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        itemCount: booksInCategory.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final book = booksInCategory[index];
                          final coverUrl = book['cover_url'];
                          final pdfUrl = book['pdf_url'];
                          final fileName = book['file_name'] ?? 'book.pdf';

                          return Stack(
                            children: [
                              Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: coverUrl != null
                                        ? NetworkImage(coverUrl)
                                        : AssetImage('assets/placeholder.jpg')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.85),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['title'] ?? 'No Title',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      book['author'] ?? 'Unknown',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.download,
                                              color: Colors.tealAccent),
                                          onPressed: isDownloading
                                              ? null
                                              : () => _downloadPdf(
                                                  pdfUrl, fileName),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.picture_as_pdf,
                                              color: Colors.redAccent),
                                          onPressed: isOpeningPdf
                                              ? null
                                              : () => _openPdf(pdfUrl),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
