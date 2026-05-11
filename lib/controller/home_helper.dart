import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeHelper {
  // বই খোলার লজিক
  static Future<void> openBook(Map<String, dynamic> book, BuildContext context) async {
    String? previewLink = book['volumeInfo']?['previewLink'];
    String? canonicalLink = book['volumeInfo']?['canonicalVolumeLink'];
    String? infoLink = book['infoLink'];

    final link = previewLink ?? canonicalLink ?? infoLink;

    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No source available for this book")),
      );
      return;
    }

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open book link")),
      );
    }
  }

  // লগআউট লজিক
  static Future<void> logout(BuildContext context, Widget loginScreen) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => loginScreen),
    );
  }
}