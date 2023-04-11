import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_seller_app/authentication/auth_screen.dart';
import 'package:foodpanda_seller_app/global/global.dart';
import 'package:foodpanda_seller_app/mainScreens/home_screen.dart';
import 'package:foodpanda_seller_app/widgets/loading_dialog.dart';

import '../widgets/custom_textfield.dart';
import '../widgets/error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void formValidation() {
    if (emailController.text.isNotEmpty) {
      if (passwordController.text.isNotEmpty) {
        loginNow();
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please write password",
              );
            });
      }
    } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please write email",
              );
            });
      }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: "Checking Credentials",
          );
        });

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!
            .setString("email", snapshot.data()!["sellerEmail"]);
        await sharedPreferences!
            .setString("name", snapshot.data()!["sellerName"]);
        await sharedPreferences!
            .setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);

        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => const HomeScreen()));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => const AuthScreen()));

        showDialog(
            context: context,
            builder: (builder) {
              return const ErrorDialog(
                message: "No record exists",
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // alignment: Alignment.bottomCenter,
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 20),
            // padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const Image(
                fit: BoxFit.fill,
                image: AssetImage(
                  "images/seller.png",
                ),
                height: 250,
                width: 350,
              ),
            ),
          ),

          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    formValidation();
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.cyan,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 10)),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
