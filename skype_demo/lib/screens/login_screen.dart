import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/resources/firebase_repositories.dart';
import 'package:flutter_projects/screens/home_screen.dart';
import 'package:flutter_projects/utils/universal_variables.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseRepositories _repository = FirebaseRepositories();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Center(child: loginButton()),
        const SizedBox(height: 10,),
        isLoginPressed ? const CircularProgressIndicator(color: Colors.white,strokeWidth: 4,) : Container(),
      ]),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UniversalVariables.senderColor,
      child: TextButton(
        onPressed: () async {
          performLogin();
        },
        child: const Text(
          "Login",
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )),
      ),
    );
  }

  void performLogin() async {
    User? user = await _repository.signIn();
    setState(() {
      isLoginPressed = true;
    });
    authenticateUser(user!);
  }

  void authenticateUser(User user) async {
    bool? isNewUser = await _repository.authenticateUser(user);
    setState(() {
      isLoginPressed = false;
    });
    if (isNewUser!) {
      await _repository.addToDb(user);
      Get.off(const HomeScreen());
    } else {
      Get.off(const HomeScreen());
    }
  }
}
