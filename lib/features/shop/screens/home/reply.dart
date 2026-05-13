import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_store/utils/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/helpers/helper_functions.dart';

class ReplyBookScreen extends StatelessWidget {
  const ReplyBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    bool dark = UHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? UColors.light : UColors.dark,
      appBar: AppBar(
        title: Text(
          "Replies",
          style: TextStyle(color: dark ? UColors.dark : UColors.light),
        ),
        backgroundColor: dark ? UColors.primary : UColors.secondary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('requested_by', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("You haven't requested any books yet."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req['title'] ?? 'No Title',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text("Category: ${req['category']}",
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text("My Comment: ${req['description']}",
                          style: const TextStyle(fontSize: 14)),
                      const Divider(height: 24),
                      const Text("Donations / Replies:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('replies')
                            .where('request_id', isEqualTo: requestId)
                            .snapshots(),
                        builder: (context, replySnapshot) {
                          if (!replySnapshot.hasData ||
                              replySnapshot.data!.docs.isEmpty) {
                            return const Text("No one donated yet.",
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 12));
                          }

                          final replies = replySnapshot.data!.docs;

                          return Column(
                            children: replies.map((replyDoc) {
                              final reply =
                                  replyDoc.data() as Map<String, dynamic>;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.person_pin,
                                    color: UColors.primary),
                                title: Text(
                                    reply['message'] ?? 'I want to donate'),
                                subtitle: Text(
                                    "Donated by: ${reply['user_name'] ?? 'Anonymous'}"),
                                trailing: reply['pdf_url'] != null
                                    ? IconButton(
                                        icon: const Icon(Icons.picture_as_pdf,
                                            color: Colors.red),
                                        onPressed: () => launchUrl(
                                            Uri.parse(reply['pdf_url'])),
                                      )
                                    : null,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
