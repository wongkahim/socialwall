import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/components/button.dart';
import 'package:socialwall/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // User sign up
  Future<void> signUp() async {
    // show loading cirlce
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // make sure passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      sigeUpFail(errMsg: "Password don't match!");
      return;
    }

    // try creating the user
    try {
      // create the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // after creating the user, create a new document in cloud firestore called Users
      final userName = emailTextController.text.trim().split('@')[0];
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email!).set({
        'username': userName, // inital username
        'bio': "Yo! How's it going? You can call me $userName.", // inital bio
        // add other additional fields as needed in future
      });

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      sigeUpFail(errMsg: e.code);
    }
  }

  // display a dialog message
  void sigeUpFail({String errMsg = ""}) {
    // pop loading circle
    Navigator.pop(context);

    // display error message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errMsg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // logo
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),

                  const SizedBox(height: 50),

                  // welcome back message
                  Text(
                    "Lets create an account for you",
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 25),

                  // email textfield
                  MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // confirm password textfield
                  MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // sign up button
                  MyButton(
                    onTap: signUp,
                    text: "Sign Up",
                  ),

                  const SizedBox(height: 25),

                  // go to register page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
