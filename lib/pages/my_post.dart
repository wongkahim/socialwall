import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/Helper/clshelper_method.dart';
import 'package:socialwall/components/wall_post.dart';
import 'package:socialwall/pages/profile_page.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _HomePageState();
}

class _HomePageState extends State<MyPostPage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // post message
  void postMessage() {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // add and store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    //clear the textfield
    setState(() {
      textController.clear();
    });
  }

  // Navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Post"),
      ),
      body: Center(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where("UserEmail", isEqualTo: currentUser.email)
                      .orderBy(
                        "TimeStamp",
                        descending: false,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          //get the message
                          final post = snapshot.data!.docs[index];
                          return WallPost(
                            postId: post.id,
                            user: post['UserEmail'],
                            message: post['Message'],
                            time: formatDate(timestamp: post['TimeStamp']),
                            // Get Likes List From Firebase, if null return []
                            likes: List<String>.from(post['Likes'] ?? []),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),

            // logged in as
            Text(
              "Logged in as: ${currentUser.email!}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
