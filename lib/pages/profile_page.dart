import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // all user
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // edit field
  Future<void> editField({String field = ""}) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit $field",
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $field",
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
            ),
          ),

          // save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              "Save",
            ),
          ),
        ],
      ),
    );

    // update in firestore (only update if there is something in the textfield)
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile Page"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final userMetadata = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(children: [
              const SizedBox(height: 50),

              // profile pic
              const Icon(
                Icons.person_pin_rounded,
                size: 70,
              ),

              const SizedBox(height: 10),

              // user email
              Text(
                currentUser.email!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),

              const SizedBox(height: 50),

              // user details
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'My Details',
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w400),
                ),
              ),

              // user name
              MyTextBox(
                text: userMetadata['username'] ?? '',
                sectionName: "username",
                onPressed: () => editField(field: 'username'),
              ),

              // bio
              MyTextBox(
                text: userMetadata['bio'] ?? '',
                sectionName: "bio",
                onPressed: () => editField(field: 'bio'),
              ),
            ]);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
