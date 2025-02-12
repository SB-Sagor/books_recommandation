import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadBookFirestore extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pdfUrlController = TextEditingController();

  void uploadBook() async {
    if (nameController.text.isEmpty ||
        authorController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        pdfUrlController.text.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection("books").add({
      'name': nameController.text.trim(),
      'author': authorController.text.trim(),
      'description': descriptionController.text.trim(),
      'pdfUrl': pdfUrlController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Book Uploaded!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Book (Firestore)")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Book Name")),
            TextField(controller: authorController, decoration: InputDecoration(labelText: "Author Name")),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
            TextField(controller: pdfUrlController, decoration: InputDecoration(labelText: "PDF URL")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: uploadBook, child: Text("Upload Book")),
          ],
        ),
      ),
    );
  }
}
