import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/posts.dart';
import '../components/text_feild.dart';
import 'package:bc_new/components/drawer.dart';

import '../helper/helper_methods.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //text controller
  final textController = TextEditingController();

//log out
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  //post review
  void postMessage(){
    //only post when something in the text feild
    if(textController.text.isNotEmpty){
      //store in the firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes' : [],
      });
    }
    //clear textfeild
    setState(() {
      textController.clear();
    });
  }


  void goToProfilePage() {

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(



      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Book Club"),
        actions: [
          //sign out button
          IconButton(onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSightOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            //book reviews feed
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("User Posts")
                    .orderBy("TimeStamp",
                  descending:false,
                ).snapshots(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        //get message
                        final post = snapshot.data!.docs[index];
                        return BookPost(message: post['Message'], user: post['UserEmail'],
                          postId: post.id, likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  }else if(snapshot.hasError){
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

            //post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //textfild
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Post a Review..',
                      obscureText: false,
                    ),
                  ),
                  //post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_up),
                  )
                ],

              ),

            ),


            //loggin in as
            Text("Logged in as: " + currentUser.email!,
              style: TextStyle(color: Colors.brown),
            ),

            const SizedBox(
              height:50,
            ),
          ],

        ),
      ),



    );
  }
}
