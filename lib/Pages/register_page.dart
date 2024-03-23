import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_feild.dart';

class RegisterPage extends StatefulWidget{
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});


  @override
  State<RegisterPage> createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage>{
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();


  void signUp() async{
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),

      ),
    );

    if(passwordTextController.text != confirmPasswordTextController.text){
      //pop loading circle
      Navigator.pop(context);
      //show error to user
      displayMessage("Passwords don't match!");
      return;
    }


    try{
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,);

      FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.email)
          .set({
        'username' : emailTextController.text.split('@')[0], //intial username
        'bio': 'Empty Bio..' //intial empty bio

      });

      if(context.mounted) Navigator.pop(context);

    }on FirebaseAuthException catch(e){
      Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }


  }


  //display invaild message
  void displayMessage(String message){
    showDialog(
      context: context,
      builder:(context) => AlertDialog( title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        //logo
                        const Icon(
                          Icons.lock,
                          size:100,
                          color: Colors.brown,
                        ),

                        const SizedBox(height: 50),

                        //welcome back message
                        Text(
                          "Lets create a new account!",
                          style: TextStyle(color: Colors.grey.shade700),



                        ),

                        const SizedBox(height: 25),

                        //email
                        MyTextField(controller: emailTextController,
                            hintText: 'Email', obscureText: false),

                        const SizedBox(height: 10),
                        //password
                        MyTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),

                        const SizedBox(height: 10),


                        //confirm password
                        MyTextField(controller: confirmPasswordTextController, hintText: 'Confirm Password', obscureText: true),

                        const SizedBox(height: 10),


                        //sign in

                        MyButton(onTap:signUp, text: 'Sign up'),

                        const SizedBox(height: 25),



                        //registar

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text("Login now!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ],

                        )

                      ],
                    )

                )
            )
        )
    );
  }

}