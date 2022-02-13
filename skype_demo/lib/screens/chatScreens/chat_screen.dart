import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_projects/enum/view_state.dart';
import 'package:flutter_projects/models/message.dart';
import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/resources/firebase_repositories.dart';
import 'package:flutter_projects/state/image_upload_state.dart';
import 'package:flutter_projects/utils/universal_variables.dart';
import 'package:flutter_projects/utils/utilities.dart';
import 'package:flutter_projects/widgets/appbar.dart';
import 'package:flutter_projects/widgets/cache_image.dart';
import 'package:flutter_projects/widgets/custom_tile.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pt;

class ChatScreen extends StatefulWidget {
  final UserData sender;
  final UserData receiver;

  const ChatScreen({Key? key, required this.sender, required this.receiver})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseRepositories _repository = FirebaseRepositories();
  final ScrollController _listScrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  bool isWriting = false;
  final UploadingState c = Get.put(UploadingState());
  bool isUploading = false;

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    sendMessage() async {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: '${widget.receiver.uid}',
        senderId: '${widget.sender.uid}',
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );
      textFieldController.clear();
      setState(() {
        isWriting = false;
      });
      await _repository.addMessageToDb(
          _message, widget.sender, widget.receiver);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Container(
            height: 35,
            width: 35,
            decoration: const BoxDecoration(
              gradient: UniversalVariables.fabGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: showBottomSheet,
              icon: const Icon(
                Icons.add,
                size: 15,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextField(
              focusNode: textFieldFocus,
              controller: textFieldController,
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (val) {
                (val.isNotEmpty && val.trim() != "")
                    ? setWritingTo(true)
                    : setWritingTo(false);
              },
              decoration: const InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: UniversalVariables.greyColor,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                fillColor: UniversalVariables.separatorColor,
              ),
            ),
          ),
          isWriting
              ? Container()
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => pickImage(source: ImageSource.gallery),
                ),
          isWriting
              ? Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: sendMessage,
                  ))
              : Container()
        ],
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Messages")
            .doc(widget.sender.uid)
            .collection('${widget.receiver.uid}')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          SchedulerBinding.instance?.addPostFrameCallback((_) {
            _listScrollController.animateTo(
                _listScrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut);
          });
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data?.docs.length,
            reverse: true,
            controller: _listScrollController,
            itemBuilder: (context, index) {
              return chatMessageItem(snapshot.data!.docs[index]);
            },
          );
        });
  }

  Widget chatMessageItem(DocumentSnapshot doc) {
    Message _message = Message.fromMap(doc.data() as Map<String, dynamic>);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        alignment: _message.senderId == widget.sender.uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == widget.sender.uid
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);

    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != "image"
        ? Text(
            message.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != 'not'
            ? CachedImage(
                url: message.photoUrl,
              )
            : const Text("Url not found");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);

    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: <Widget>[
          Flexible(
            // عشان الفيلد بتاع الشات يبقي تحت لان الليست فيو هتبقي فوقيها و هكذا يعني
            child: messageList(),
          ),
          Obx(() => c.viewState.value == ViewState.loading
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: 10),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Container()),
          chatControls(),
        ],
      ),
    );
  }

  void pickImage({required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    String imageName = pt.basename(selectedImage.path);
    if (imageName != "file.txt") {
      await _repository.uploadImage(
        image: selectedImage,
        receiverId: '${widget.receiver.uid}',
        senderId: '${widget.sender.uid}',
        uploadingState: c,
      );
    }
  }

  void showBottomSheet() async {
    await Get.bottomSheet(Container(
      color: UniversalVariables.blackColor,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: <Widget>[
                TextButton(
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Content and tools",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              children: <Widget>[
                ModalTile(
                  title: "Media",
                  subtitle: "Share Photos and Video",
                  icon: Icons.image,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
                ModalTile(
                  title: "File",
                  subtitle: "Share files",
                  icon: Icons.tab,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
                ModalTile(
                  title: "Contact",
                  subtitle: "Share contacts",
                  icon: Icons.contacts,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
                ModalTile(
                  title: "Location",
                  subtitle: "Share a location",
                  icon: Icons.add_location,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
                ModalTile(
                  title: "Schedule Call",
                  subtitle: "Arrange a skype call and get reminders",
                  icon: Icons.schedule,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
                ModalTile(
                  title: "Create Poll",
                  subtitle: "Share polls",
                  icon: Icons.poll,
                  onTap: () => pickImage(source: ImageSource.gallery),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      centerTitle: false,
      title: Text(
        '${widget.receiver.name}',
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.video_call,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.phone,
          ),
          onPressed: () {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function() onTap;

  const ModalTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        leading: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subTitle: Text(
          subtitle,
          style: const TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        onLongPress: () {},
        trailing: Container(),
        icon: Container(),
        onTap: onTap,
      ),
    );
  }
}
