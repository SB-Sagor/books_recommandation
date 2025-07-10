import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_store/widgets/custome_textfield.dart';
import 'package:book_store/widgets/custome_button.dart';
import 'package:book_store/widgets/app_colors.dart';

class ReplyScreen extends StatefulWidget {
  const ReplyScreen({super.key});

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  List<dynamic> myRequests = [];
  Map<String, List<dynamic>> repliesMap = {};
  final replyMessageController = TextEditingController();
  File? replyFile;
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String? activeRequestId;

  @override
  void initState() {
    super.initState();
    fetchMyRequests();
  }

  Future<void> fetchMyRequests() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final res = await Supabase.instance.client
        .from('requests')
        .select('*, profiles(name)')
        .eq('requested_by', user.id)
        .order('created_at')
        .execute();
    if (res.data != null && mounted) {
      final list = List<Map<String, dynamic>>.from(res.data);
      setState(() => myRequests = list);
      final ids = list.map((r) => r['id']).toList();
      final replyRes = await Supabase.instance.client
          .from('replies')
          .select('*, profiles(name)')
          .in_('request_id', ids)
          .execute();
      final replies = List<Map<String, dynamic>>.from(replyRes.data);
      repliesMap = {
        for (var id in ids)
          '$id': replies.where((r) => r['request_id'] == id).toList()
      };
      if (mounted) setState(() {});
    }
  }

  Future<void> pickReplyFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null && mounted) {
      setState(() => replyFile = File(result.files.single.path!));
    }
  }

  Future<void> submitReply() async {
    if (!_formKey.currentState!.validate() || activeRequestId == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    if (mounted) setState(() => isSubmitting = true);
    String? pdfUrl;
    if (replyFile != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(replyFile!.path)}';
      await Supabase.instance.client.storage
          .from('books')
          .upload(fileName, replyFile!);
      pdfUrl =
          Supabase.instance.client.storage.from('books').getPublicUrl(fileName);
    }
    await Supabase.instance.client.from('replies').insert({
      'request_id': activeRequestId,
      'replied_by': user.id,
      'pdf_url': pdfUrl,
      'message': replyMessageController.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
    replyMessageController.clear();
    replyFile = null;
    Navigator.pop(context);
    await fetchMyRequests();
    if (mounted) {
      setState(() {
        isSubmitting = false;
        activeRequestId = null;
      });
    }
  }

  Widget replyInput(Map req) {
    final reqId = req['id']?.toString();
    activeRequestId = reqId;
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("📥 Reply to '${req['title']}'",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: replyMessageController,
                labelText: "Message",
                hintText: "Enter your reply",
                icon: Icons.message,
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? "Reply message is required"
                    : null,
              ),
              SizedBox(height: 12),
              customButton(
                replyFile == null
                    ? "Attach PDF (optional)"
                    : p.basename(replyFile!.path),
                pickReplyFile,
              ),
              SizedBox(height: 12),
              isSubmitting
                  ? CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)
                  : customButton("Submit Reply", submitReply),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "📥 My Book Requests",
          style: TextStyle(color: AppColors.card),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: myRequests.map((req) {
            final replies = List<Map<String, dynamic>>.from(
                repliesMap['${req['id']}'] ?? []);
            return Card(
              margin: EdgeInsets.symmetric(vertical: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req['title'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${req['category']} • ${req['description']}"),
                    SizedBox(height: 10),
                    customButton(
                      "Reply",
                      () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: replyInput(req),
                        ),
                      ),
                    ),
                    if (replies.isNotEmpty) ...[
                      Divider(),
                      Text("💬 Replies",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...replies
                          .map((r) => ListTile(
                                title: Text(r['message']),
                                subtitle: Text(
                                    "By ${r['profiles']?['name'] ?? 'Unknown'}"),
                                trailing: r['pdf_url'] != null
                                    ? IconButton(
                                        icon: Icon(Icons.picture_as_pdf,
                                            color: Colors.teal),
                                        onPressed: () =>
                                            launchUrl(Uri.parse(r['pdf_url'])),
                                      )
                                    : null,
                              ))
                          .toList(),
                    ]
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
