import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late String senderId;
  late String receiverId;
  late String type;
  late String message;
  late Timestamp timestamp;
  String photoUrl = 'not';

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.type,
      required this.message,
      required this.timestamp});

  //Will be only called when you wish to send an image
  Message.imageMessage(
      {required this.senderId,
      required this.receiverId,
      required this.message,
      required this.type,
      required this.timestamp,
      required this.photoUrl});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['receiverId'] = receiverId;
    map['type'] = type;
    map['message'] = message;
    map['timestamp'] = timestamp;
    map['photoUrl'] = photoUrl;
    return map;
  }

  Map<String, dynamic> toImageMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['receiverId'] = receiverId;
    map['type'] = type;
    map['message'] = message;
    map['timestamp'] = timestamp;
    map['photoUrl'] = photoUrl;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    type = map['type'];
    message = map['message'];
    timestamp = map['timestamp'];
    photoUrl = map['photoUrl'];
  }
}
