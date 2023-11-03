import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/Helper/clshelper_method.dart';
import 'package:socialwall/components/comment.dart';
import 'package:socialwall/components/comment_button.dart';
import 'package:socialwall/components/delete_button.dart';
import 'package:socialwall/components/edit_button.dart';
import 'package:socialwall/components/like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text controller
  final commentTextController = TextEditingController();
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    //if currentUser like, the like button activtive
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComment({String commentText = ""}) {
    //write the comment to firestore under the comment collection
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add(
      {
        "CommentText": commentText,
        "CommentBy": currentUser.email,
        "CommentTime": Timestamp.now(),
      },
    );
  }

  // show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment.."),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              //pop the dialog
              Navigator.pop(context);

              // clear text
              commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),

          // save button
          TextButton(
            onPressed: () {
              // add comment
              addComment(commentText: commentTextController.text);

              //pop the dialog
              Navigator.pop(context);

              // clear text
              commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  // edit a post
  Future<void> editPost({String postId = ""}) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit message",
        ),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new message",
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
          .doc(postId)
          .update({
        "Message": newValue,
      });
    }
  }

  // delete a post
  void deletePost() {
    // show a dialog box asking for confirmation before deleting the message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          // CANCEL
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // DELETE
          TextButton(
            onPressed: () async {
              // delete the comments from firestore first
              // (if you only delete the post, the comments willl still be stored in firestore)
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();
              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete()
                    .then((value) => debugPrint("comment deleted"))
                    .catchError(
                      (error) => debugPrint("failed to delete comment: $error"),
                    );
              }

              // then delete the post
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => debugPrint("post deleted"))
                  .catchError(
                    (error) => debugPrint("failed to delete post: $error"),
                  );

              // dismiss the dialog box
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Count Comment
  void countComments(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) async {
    setState(() {
      commentCount = snapshot.data!.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),

            // wallpost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // group of text(message + user email)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // message
                    Text(widget.message),

                    const SizedBox(height: 5),

                    // user
                    Row(
                      children: [
                        Text(
                          widget.user,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(" ✍🏻  ",
                            style: TextStyle(
                              color: Colors.grey[400],
                            )),
                        Text(
                          widget.time,
                          style: TextStyle(color: Colors.grey[400]),
                        )
                      ],
                    ),
                  ],
                ),

                // edit button
                if (widget.user == currentUser.email)
                  EditButton(
                    iconData: Icons.edit_document,
                    onTap: () => editPost(postId: widget.postId),
                  ),

                // delete button
                if (widget.user == currentUser.email)
                  DeleteButton(onTap: deletePost)
              ],
            ),

            const SizedBox(height: 20),

            //Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LIKE
                Column(
                  children: [
                    // like button
                    LikeButton(isLiked: isLiked, onTap: toggleLike),

                    const SizedBox(height: 5),

                    //like count
                    Text(
                      widget.likes.length.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(width: 15),

                // COMMENT
                Column(
                  children: [
                    // comment button
                    CommentButton(onTap: showCommentDialog),

                    const SizedBox(height: 5),

                    //comment count
                    Text(
                      commentCount.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // comments under the post
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //show loading circle if no data yet
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  shrinkWrap: true, // for nested lists
                  physics:
                      const NeverScrollableScrollPhysics(), //Doesn't Let User Scroll
                  children: snapshot.data!.docs.map((doc) {
                    // get the comment
                    final commentData = doc.data() as Map<String, dynamic>;

                    final commentId = doc.id;

                    // count comment
                    Future.delayed(Duration.zero, () async {
                      countComments(snapshot);
                    });

                    // return the comment
                    return WallComment(
                      text: commentData['CommentText'],
                      user: commentData['CommentBy'],
                      time: formatDate(timestamp: commentData['CommentTime']),
                      postId: widget.postId,
                      commentId: commentId,
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
