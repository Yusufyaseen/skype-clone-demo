import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/resources/firebase_repositories.dart';
import 'package:flutter_projects/screens/chatScreens/chat_screen.dart';
import 'package:flutter_projects/utils/universal_variables.dart';
import 'package:flutter_projects/widgets/custom_tile.dart';
import 'package:get/get.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<UserData> allUsers = [];
  String query = "";
  TextEditingController searchController = TextEditingController();
  final FirebaseRepositories _repository = FirebaseRepositories();
  late UserData currentUser;

  Future<void> init(User? user) async {
    List<UserData> list = await _repository.fetchAllUsers(user);
    if (!mounted) return;
    setState(() {
      allUsers = list;
      currentUser = UserData(
        uid: user?.uid,
        profilePhoto: user?.photoURL,
        name: user?.displayName,
      );
    });
  }

  buildSuggestions(String query) {
    final List<UserData> suggestionList = query.isEmpty
        ? []
        : allUsers.where((UserData user) {
            String _getUsername = user.username!.toLowerCase();
            String _query = query.toLowerCase();
            String _getName = user.name!.toLowerCase();
            bool matchesUsername = _getUsername.contains(_query);
            bool matchesName = _getName.contains(_query);

            return (matchesUsername || matchesName);

            // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
            //     (user.name.toLowerCase().contains(query.toLowerCase()))),
          }).toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          UserData searchedUser = UserData(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username,
          );

          return CustomTile(
            margin: const EdgeInsets.only(left: 10),
            mini: false,
            onTap: () {
              Get.to(ChatScreen(
                sender: currentUser,
                receiver: searchedUser,
              ));
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage("${searchedUser.profilePhoto}"),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              "${searchedUser.username}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subTitle: Text(
              "${searchedUser.name}",
              style: const TextStyle(color: UniversalVariables.greyColor),
            ),
            onLongPress: () {},
            icon: Container(),
            trailing: Container(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _repository.getCurrentUser(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          init(snapshot.data);
          return Scaffold(
              backgroundColor: UniversalVariables.blackColor,
              appBar: NewGradientAppBar(
                gradient: const LinearGradient(colors: [
                  UniversalVariables.gradientColorStart,
                  UniversalVariables.gradientColorEnd
                ]),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight + 20),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          query = val;
                        });
                      },
                      cursorColor: UniversalVariables.blackColor,
                      autofocus: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 35,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              query = "";
                            });
                          },
                        ),
                        border: InputBorder.none,
                        hintText: "Search",
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 35,
                          color: Color(0x88ffffff),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: buildSuggestions(query));
        });
  }
}
