


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bc_new/components/like_btn.dart';
import 'package:bc_new/components/comment_btn.dart';
import '../helper/helper_methods.dart';
import 'package:bc_new/components/comment.dart';
import 'delete_btn.dart';

class BookPost extends StatefulWidget{
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  const BookPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,

  });

  @override
  State<BookPost> createState() => _BookPostState();
}

class _BookPostState extends State<BookPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  //text controller
  final _commentTextController = TextEditingController();

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like button
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });


    DocumentReference postRef = FirebaseFirestore.instance.collection('User Posts').doc(
        widget.postId
    );

    if(isLiked){
      //if post is liked , add user to the likes feild
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    }else{
      //remove user if the post is unliked
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }

  }

  //add comment
  void addComment(String commentText){
    //write comment to the firestore
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "CommentText": commentText,
      "CommentBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void showCommentDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a Comment..."),
        ),
        actions: [

          //cancel button
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              //clear comment
              _commentTextController.clear();
            },
            child: Text("cancel"),
          ),
          //post button
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);

              Navigator.pop(context);

              //clear comment
              _commentTextController.clear();

            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }
  //delete post
  void deletePost(){
    //confirmation box to delete post
    showDialog(context: context,
      builder:(context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions:[
          //cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("cancel"),
          ),

          TextButton(
            onPressed: () async {
              //delete comments from firebase first
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("comments")
                  .get();

              for(var doc in commentDocs.docs){
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("comments")
                    .doc(doc.id)
                    .delete();
              }
              FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).delete()
                  .then((value) => print("post deleted!")).catchError((error) => print("faild to delete post: $error"));

              Navigator.pop(context);

            },
            child: const Text("Delete"),
          ),
        ],

        //cancel
      ),
    );

  }
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //text group
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message post
                  Text(widget.message),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Text(widget.user, style: TextStyle(color: Colors.brown[400]),
                      ),
                      Text(" - ",  style: TextStyle(color: Colors.brown[400]),
                      ),
                      Text(widget.time,  style: TextStyle(color: Colors.brown[400]),
                      ),
                    ],
                  )


                ],
              ),
              //delete button
              if(widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),


          const SizedBox(height: 20),
          // button

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //like button

              Column(
                children: [
                  likeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  const SizedBox(height: 5),
                  //like count
                  Text(widget.likes.length.toString(),
                    style: TextStyle(color: Colors.brown),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              //comment button
              Column(
                children: [

                  CommentButton(
                    onTap: showCommentDialog,
                  ),
                  const SizedBox(height: 5),
                  //like count
                  Text('0',
                    style: TextStyle(color: Colors.brown),
                  ),
                ],
              ),

            ],

          ),
          const SizedBox(height: 20),



          //comment under post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("User Posts")
                .doc(widget.postId).collection("comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )



          //profile pic
          /*Container(
            decoration:
             BoxDecoration(shape: BoxShape.circle, color: Colors.brown[100]),
            padding: EdgeInsets.all(10),
            child: const Icon(
                Icons.person,
              color: Colors.brown,
            ),
          ),
          */
        ],
      ),
    );
  }
}
