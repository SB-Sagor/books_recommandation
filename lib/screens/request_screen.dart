import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_store/widgets/custome_textfield.dart';
import 'package:book_store/widgets/custome_button.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'reply_screen.dart'; // Make sure this screen exists

class RequestBookScreen extends StatefulWidget {
  const RequestBookScreen({super.key});

  @override
  State<RequestBookScreen> createState() => _RequestBookScreenState();
}

class _RequestBookScreenState extends State<RequestBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  bool isSubmitting = false;

  Future<void> ensureProfileExists() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response =
    await supabase.from('profiles').select().eq('id', user.id).execute();

    final existingProfiles = response.data as List<dynamic>?;

    if (existingProfiles == null || existingProfiles.isEmpty) {
      final insertRes = await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'name': user.email?.split('@').first ?? 'Anonymous',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }).execute();

      if (insertRes.status != 201) {
        print("❌ Failed to insert profile: ${insertRes.data}");
      } else {
        print("✅ Profile successfully created for ${user.email}");
      }
    } else {
      print("✅ Profile already exists for ${user.email}");
    }
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to submit a request.")),
      );
      return;
    }

    setState(() => isSubmitting = true);
    await ensureProfileExists();

    try {
      final response = await Supabase.instance.client.from('requests').insert({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': categoryController.text.trim(),
        'requested_by': user.id,
        'created_at': DateTime.now().toIso8601String(),
      }).execute();

      if (response.status == 201) {
        titleController.clear();
        categoryController.clear();
        descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Book request submitted!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReplyScreen()),
        );
      } else {
        print("❌ Request insert failed: ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit request.")),
        );
      }
    } catch (e) {
      print("❌ Exception while submitting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error occurred.")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📩 Submit Book Request",
            style: TextStyle(color: AppColors.card)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Enter details below",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              SizedBox(height: 24),
              CustomTextFormField(
                controller: titleController,
                hintText: "Enter book title",
                labelText: "Title",
                icon: Icons.book,
                keyboardType: TextInputType.text,
                validator: (value) => value!.isEmpty ? "Title is required" : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: categoryController,
                hintText: "Enter category",
                labelText: "Category",
                icon: Icons.category,
                keyboardType: TextInputType.text,
                validator: (value) =>
                value!.isEmpty ? "Category is required" : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: descriptionController,
                hintText: "Enter comment",
                labelText: "Comment",
                icon: Icons.comment,
                keyboardType: TextInputType.multiline,
                validator: (value) =>
                value!.isEmpty ? "Comment is required" : null,
              ),
              SizedBox(height: 24),
              isSubmitting
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
                  : customButton("Send Request", submitRequest),
            ],
          ),
        ),
      ),
    );
  }
}
