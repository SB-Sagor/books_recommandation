import 'package:book_store/features/shop/screens/home/reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_store/utils/constants/color.dart';
import '../../../../common/widgets/buttons/custom_button.dart';
import '../../../../common/widgets/textfields/custom_textfield.dart';
import '../../../../services/request_servic.dart';
import '../../../../utils/helpers/helper_functions.dart';

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

  final RequestService _requestService = RequestService();

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to submit a request.")),
      );
      return;
    }

    setState(() => isSubmitting = true);
    await _requestService;

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': categoryController.text.trim(),
        'requested_by': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      titleController.clear();
      categoryController.clear();
      descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book request submitted!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReplyBookScreen()),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit request.")),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
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
    bool dark = UHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? UColors.light : UColors.dark,
      appBar: AppBar(
        title: Text("Submit Book Request",
            style: TextStyle(
                color: dark ? UColors.dark : UColors.light, fontSize: 18.sp)),
        backgroundColor: dark ? UColors.primary : UColors.secondary,
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
                  "Request for book",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              CustomTextFormField(
                controller: titleController,
                hintText: "Enter book title",
                labelText: "Title",
                icon: Icons.book,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value!.isEmpty ? "Title is required" : null,
              ),
              SizedBox(height: 16.h),
              CustomTextFormField(
                controller: categoryController,
                hintText: "Enter category",
                labelText: "Category",
                icon: Icons.category,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value!.isEmpty ? "Category is required" : null,
              ),
              SizedBox(height: 16.h),
              CustomTextFormField(
                controller: descriptionController,
                hintText: "Enter comment",
                labelText: "Comment",
                icon: Icons.comment,
                keyboardType: TextInputType.multiline,
                validator: (value) =>
                    value!.isEmpty ? "Comment is required" : null,
              ),
              SizedBox(height: 24.h),
              isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: UColors.primary,
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
