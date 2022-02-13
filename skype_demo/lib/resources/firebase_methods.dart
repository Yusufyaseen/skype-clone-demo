import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projects/models/message.dart';
import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/state/image_upload_state.dart';
import 'package:flutter_projects/utils/utilities.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
class FirebaseMethods {
  UserData user = UserData();
  late firebase_storage.Reference _ref;
  late firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  late firebase_storage.UploadTask _uploadTask;
  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }

  Future<User?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return (await FirebaseAuth.instance.signInWithCredential(credential)).user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.isEmpty ? true : false;
  }

  Future<void> addToDb(User data) async {
    String username = Utils.getUsername(data.email);

    user = UserData(
      uid: data.uid,
      email: data.email,
      name: data.displayName,
      profilePhoto: data.photoURL,
      username: username,
    );

    FirebaseFirestore.instance
        .collection("Users")
        .doc(data.uid)
        .set(user.toMap(user));
  }

  Future<void> signOutFromGoogle() async {
    // await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    return await FirebaseAuth.instance.signOut();
  }

  Future<List<UserData>> fetchAllUsers(User? user) async {
    List<UserData> allUsers = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Users").get();

    for (var doc in querySnapshot.docs) {
      allUsers.add(UserData.fromMap(doc.data() as Map<String, dynamic>));
    }

    allUsers = allUsers.where((doc) => doc.uid != user?.uid).toList();
    return allUsers;
  }

  Future<void> addMessageToDb(
      Message message, UserData sender, UserData receiver) async {
    Map<String, dynamic> map = message.toMap();

    await FirebaseFirestore.instance
        .collection("Messages")
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    await FirebaseFirestore.instance
        .collection("Messages")
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      _ref = firebase_storage.FirebaseStorage.instance
          .ref("chat/${DateTime.now().millisecondsSinceEpoch}");
      _uploadTask =
       _ref.putFile(imageFile);
      late String url;
        (await _uploadTask.whenComplete(() async =>
        url = await _ref.getDownloadURL()));
   print("-------------$url");
      return url;
    } catch (e) {
      return e.toString();
    }
  }


  void setImageMsg(String url, String receiverId, String senderId) async {
    Message message;

    message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    Map<String, dynamic> map = message.toImageMap();

    await FirebaseFirestore.instance
        .collection("Messages")
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    await FirebaseFirestore.instance
        .collection("Messages")
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }




  Future<void> uploadImage(File image, String receiverId, String senderId, UploadingState uploadingState) async{

    uploadingState.setToLoading();

    String url = await uploadImageToStorage(image);

    setImageMsg(url, receiverId, senderId);

    uploadingState.setToIdle();


  }
}
