import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final String name, author, category, imageUrl, pdfUrl;

  BookDetailScreen({required this.name, required this.author, required this.category, required this.imageUrl, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Image.network(imageUrl, height: 200),
          SizedBox(height: 10),
          Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Author: $author"),
          Text("Category: $category"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => launch(pdfUrl),
            child: Text("Download PDF"),
          ),
        ],
      ),
    );
  }
}
