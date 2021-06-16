import 'package:binge_buddy/models/MediaUIModel.dart';
import 'package:binge_buddy/screens/LoginScreen.dart';
import 'package:binge_buddy/secureValues/Secure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'ProfileScreen.dart';
import 'FriendScreen.dart';
import 'MoviesScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget{
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Secure s = new Secure();
    FirebaseFirestore.instance.collection('secure').doc("values").get().then((DocumentSnapshot documentSnapshot){
      Secure.APIKEY = documentSnapshot["API_KEY"];
    });
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1,
      // Choose the nav bar style with this property.
    );
  }

}

List<Widget> _buildScreens() {
  return [
    FriendScreen(),
    MoviesScreen(),
    ProfileScreen()
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems() {
  return [
    PersistentBottomNavBarItem(
      icon: Icon(CupertinoIcons.person_3),
      title: ("Buddies"),
      activeColorPrimary: CupertinoColors.activeGreen,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(CupertinoIcons.square_stack),
      title: ("Movies/TV"),
      activeColorPrimary: CupertinoColors.systemRed,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(CupertinoIcons.profile_circled),
      title: ("Profile"),
      activeColorPrimary: CupertinoColors.activeBlue,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
  ];
}