import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/components/edit_button.dart';

class WallComment extends StatefulWidget {
  final String postId;
  final String commentId;
  final String text;
  final String user;
  final String time;

  const WallComment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.postId,
    required this.commentId,
  });

  @override
  State<WallComment> createState() => _WallCommentState();
}

class _WallCommentState extends State<WallComment> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // edit a comment
  Future<void> editComment() async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit comment",
        ),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new comment",
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
      await FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postId)
          .collection("Comments")
          .doc(widget.commentId)
          .update({"CommentText": newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // comment
                Text(widget.text),

                const SizedBox(height: 5),

                // user, time
                Row(
                  children: [
                    Text(
                      widget.user,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(" 📝  ",
                        style: TextStyle(
                          color: Colors.grey[400],
                        )),
                    Text(
                      widget.time,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // edit button
          if (widget.user == currentUser.email)
            EditButton(
              iconData: Icons.edit_rounded,
              onTap: editComment,
            ),
        ],
      ),
    );
  }
}
