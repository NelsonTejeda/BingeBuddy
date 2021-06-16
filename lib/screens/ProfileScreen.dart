import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_restart/flutter_restart.dart';

class ProfileScreen extends StatefulWidget{
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            child: ElevatedButton(
              child: Text("SIGN OUT"),
              onPressed: () async {
                auth.signOut();
                await FlutterRestart.restartApp();
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ),
        )
    );
  }

}