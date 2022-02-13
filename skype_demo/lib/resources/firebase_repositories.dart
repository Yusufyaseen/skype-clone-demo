import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projects/models/message.dart';
import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/state/image_upload_state.dart';
import './firebase_methods.dart';

class FirebaseRepositories {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User?> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<User?> signIn() => _firebaseMethods.signInWithGoogle();

  Future<bool?> authenticateUser(User user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addToDb(User user) => _firebaseMethods.addToDb(user);

  Future<void> signOut() => _firebaseMethods.signOutFromGoogle();

  Future<List<UserData>> fetchAllUsers(User? user) => _firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(Message message, UserData sender, UserData receiver) => _firebaseMethods.addMessageToDb(message,sender,receiver);

  Future<void> uploadImage({
    required File image,
    required String receiverId,
    required String senderId,
    required UploadingState uploadingState
  }) =>
      _firebaseMethods.uploadImage(image, receiverId, senderId, uploadingState);
}
