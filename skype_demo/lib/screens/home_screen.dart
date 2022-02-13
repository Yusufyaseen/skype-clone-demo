import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/screens/pageViews/chat_list_screen.dart';
import 'package:flutter_projects/utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    // double _labelFontSize = 10;
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children:  const[
           ChatListScreen(),
          Center(
            child: Text("Call Logs",style: TextStyle(color: Colors.white),),
          ),
          Center(
            child: Text("Contact Screen",style: TextStyle(color: Colors.white),),
          ),
        ],

      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CupertinoTabBar(

          onTap: navigationTapped,
          currentIndex: _page,
          backgroundColor: UniversalVariables.blackColor,
          items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat,
              color: (_page == 0) ? UniversalVariables.lightBlueColor : UniversalVariables.greyColor,
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call,
                color: (_page == 1) ? UniversalVariables.lightBlueColor : UniversalVariables.greyColor,
              ),
              label: "Calls",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone,
                color: (_page == 2) ? UniversalVariables.lightBlueColor : UniversalVariables.greyColor,
              ),
              label: 'Contacts',

            ),

          ],
        ),
      ),
    );
  }


}
