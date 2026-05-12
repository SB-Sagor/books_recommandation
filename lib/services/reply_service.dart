import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class ReplyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snap = await _db.collection('requests')
        .where('requested_by', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<List<Map<String, dynamic>>> getReplies(String requestId) async {
    final snap = await _db.collection('replies')
        .where('request_id', isEqualTo: requestId)
        .get();
    return snap.docs.map((doc) => doc.data()).toList();
  }

  Future<void> sendReply({
    required String requestId,
    required String message,
    File? file,
  }) async {
    final user = _auth.currentUser;
    String? pdfUrl;

    if (file != null) {
      final name = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final ref = FirebaseStorage.instance.ref().child('books').child(name);
      await ref.putFile(file);
      pdfUrl = await ref.getDownloadURL();
    }

    await _db.collection('replies').add({
      'request_id': requestId,
      'replied_by': user?.uid,
      'pdf_url': pdfUrl,
      'message': message,
      'created_at': FieldValue.serverTimestamp(),
      'user_name': user?.displayName ?? "User",
    });
  }
}