import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final dynamic bookData;
  final VoidCallback onTap;

  const BookCard({super.key, required this.bookData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var book = bookData['volumeInfo'];
    var imageUrl = book['imageLinks']?['thumbnail'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                    : const Center(child: Icon(Icons.book, size: 50, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book['title'] ?? "No Title",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}