import 'dart:io';
import 'package:book_store/screens/uploaded_books_screen.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'package:book_store/widgets/custome_button.dart';
import 'package:book_store/widgets/custome_textfield.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadBookScreen extends StatefulWidget {
  @override
  _UploadBookScreenState createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  File? selectedFile;
  File? coverImage;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  String? selectedCategory;
  bool isUploading = false;
  double fakeProgress = 0.0;

  final List<String> categories = [
    'Horror',
    'Science',
    'Biography',
    'History',
    'Trending',
    'Popular',
  ];

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => coverImage = File(result.files.single.path!));
    }
  }

  Future<void> simulateProgress() async {
    fakeProgress = 0.0;
    while (fakeProgress < 0.9 && isUploading) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        fakeProgress += 0.02;
      });
    }
  }

  Future<void> uploadBook() async {
    if (!_formKey.currentState!.validate() || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select a PDF")),
      );
      return;
    }

    setState(() {
      isUploading = true;
      fakeProgress = 0.0;
    });

    simulateProgress();

    try {
      final supabase = Supabase.instance.client;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(selectedFile!.path)}';

      await supabase.storage.from('books').upload(
            fileName,
            selectedFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage.from('books').getPublicUrl(fileName);

      String? coverUrl;
      if (coverImage != null) {
        final coverName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(coverImage!.path)}';

        await supabase.storage.from('covers').upload(
              coverName,
              coverImage!,
              fileOptions: const FileOptions(upsert: true),
            );

        coverUrl = supabase.storage.from('covers').getPublicUrl(coverName);
      }

      await supabase.from('books').insert({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'category': selectedCategory,
        'pdf_url': publicUrl,
        'file_name': p.basename(selectedFile!.path),
        'created_at': DateTime.now().toIso8601String(),
        'cover_url': coverUrl,
      });

      setState(() {
        fakeProgress = 1.0;
      });
      await Future.delayed(Duration(milliseconds: 300));

      await Future.delayed(
          Duration(milliseconds: 300)); // optional delay for smoothness

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UploadedBooksScreen()),
      );

      setState(() {
        selectedFile = null;
        coverImage = null;
        titleController.clear();
        authorController.clear();
        selectedCategory = null;
        fakeProgress = 0.0;
      });
    } catch (e, stack) {
      print("❌ Upload failed: $e");
      print("📉 Stack trace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("📚 Upload Book", style: TextStyle(color: AppColors.card)),
        backgroundColor: AppColors.primary,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Fill in the book details",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              SizedBox(height: 24.h),
// Title Field
              CustomTextFormField(
                controller: titleController,
                labelText: "Book Title",
                hintText: "e.g. The Alchemist",
                icon: Icons.title,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? "Title is required" : null,
              ),
              SizedBox(height: 16.h),

// Author Field
              CustomTextFormField(
                controller: authorController,
                labelText: "Author Name",
                hintText: "e.g. Paulo Coelho",
                icon: Icons.person,
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? "Author is required"
                    : null,
              ),

              SizedBox(height: 16.h),

              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                decoration: InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.category, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value == null ? "Category is required" : null,
              ),
              SizedBox(height: 20.h),

              // Cover Image Picker
              customButton(
                coverImage == null
                    ? "Choose Cover Image"
                    : "📷 ${p.basename(coverImage!.path)}",
                pickCoverImage,
              ),
              SizedBox(height: 12.h),

              if (coverImage != null)
                Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                    image: DecorationImage(
                      image: FileImage(coverImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 20.h),

              // PDF Picker
              customButton(
                selectedFile == null
                    ? "Choose PDF"
                    : "📎 ${p.basename(selectedFile!.path)}",
                pickFile,
              ),
              SizedBox(height: 20.h),

              // Upload Button or Progress
              isUploading
                  ? Column(
                      children: [
                        LinearProgressIndicator(
                          value: fakeProgress,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.teal,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Uploading... ${(fakeProgress * 100).toStringAsFixed(0)}%",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    )
                  : customButton("Upload Book", uploadBook),
            ],
          ),
        ),
      ),
    );
  }
}
