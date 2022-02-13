import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/resources/firebase_repositories.dart';
import 'package:flutter_projects/utils/universal_variables.dart';
import 'package:flutter_projects/utils/utilities.dart';
import 'package:flutter_projects/widgets/appbar.dart';
import 'package:flutter_projects/widgets/custom_tile.dart';
import 'package:get/get.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String currentUserId;
  late String initials;
  final FirebaseRepositories _repository = FirebaseRepositories();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _repository.getCurrentUser(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: UniversalVariables.blackColor,
              appBar: CustomAppBar(
                  title: UserCircle(
                    title: Utils.getInitials(snapshot.data!.displayName!),
                  ),
                  actions: <Widget>[
                    IconButton(

                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.toNamed('/search_screen');
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                  leading: IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  centerTitle: true),
              body: ChatListContainer(
                currentUserId: snapshot.data!.uid,
              ),
              floatingActionButton: const NewChatButton(),
            );
          } else {
            return Text(snapshot.toString());
          }
        });
  }
}

class ChatListContainer extends StatefulWidget {
  final String currentUserId;

  const ChatListContainer({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 5,
        itemBuilder: (ctx, index) {
          return CustomTile(
            mini: false,
            onTap: () {},
            title: const Text(
              "The CS Guy",
              style: TextStyle(
                  color: Colors.white, fontFamily: "Arial", fontSize: 19),
            ),
            subTitle: const Text(
              "Hello",
              style: TextStyle(
                color: UniversalVariables.greyColor,
                fontSize: 14,
              ),
            ),
            leading: Container(
              constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
              child: Stack(
                children: <Widget>[
                  const CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                        "https://yt3.ggpht.com/a/AGF-l7_zT8BuWwHTymaQaBptCy7WrsOD72gYGp-puw=s900-c-k-c0xffffffff-no-rj-mo"),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 13,
                      width: 13,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UniversalVariables.onlineDotColor,
                          border: Border.all(
                              color: UniversalVariables.blackColor, width: 2)),
                    ),
                  )
                ],
              ),
            ),
            icon: Container(),
            trailing: Container(),
            onLongPress: () {},
          );
        });
  }
}

class UserCircle extends StatelessWidget {
  final String title;

  const UserCircle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: UniversalVariables.separatorColor,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: UniversalVariables.lightBlueColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: UniversalVariables.onlineDotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: UniversalVariables.blackColor,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  const NewChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: UniversalVariables.fabGradient,
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}
