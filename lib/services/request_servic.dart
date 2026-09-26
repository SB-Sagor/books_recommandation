import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> ensureProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('profiles').doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('profiles').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'name': user.email?.split('@').first ?? 'Anonymous',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> createBookRequest({
    required String title,
    required String description,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await ensureProfileExists();

    await _firestore.collection('requests').add({
      'title': title,
      'description': description,
      'category': category,
      'requested_by': user.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}