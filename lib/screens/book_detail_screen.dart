import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final String title, author, description, imageUrl, previewLink;
  final String? pdfUrl;

  BookDetailScreen({
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.previewLink,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(imageUrl, height: 200)),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("by $author", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            Text(description),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(previewLink)),
              icon: Icon(Icons.book),
              label: Text("Read Preview"),
            ),
            if (pdfUrl != null)
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(pdfUrl!)),
                icon: Icon(Icons.download),
                label: Text("Download PDF"),
              ),
          ],
        ),
      ),
    );
  }
}
