import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/resources/firebase_repositories.dart';
import 'package:flutter_projects/screens/chatScreens/chat_screen.dart';
import 'package:flutter_projects/screens/home_screen.dart';
import 'package:flutter_projects/screens/login_screen.dart';
import 'package:flutter_projects/screens/search_screen.dart';
import 'package:get/get.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp({Key? key}) : super(key: key);
  final FirebaseRepositories _repository = FirebaseRepositories();

  @override
  Widget build(BuildContext context) {
    // _repository.signOut();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skype Demo',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/search_screen', page: () => const SearchScreen()),
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          }),
    );
  }
}
