import 'package:binge_buddy/screens/CreateAccountScreen.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreen createState() => _LoginScreen();
}

 class _LoginScreen extends State<LoginScreen>{
  final email = TextEditingController();
  final password = TextEditingController();
  final snackBarLoggedIn = SnackBar(content: Text('Logged In!'));
  final snackBarUserNotFound = SnackBar(content: Text('User not found'));
  final snackBarIncorrect = SnackBar(content: Text('Email or password is incorrect'));
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    if(user != null){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    }
    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: true,
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: FlutterLogo(
                  size: 300,
                  style: FlutterLogoStyle.markOnly,
                )
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'email'
                    ),
                    controller: email,
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'password'
                    ),
                    controller: password,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: ElevatedButton(
                    child: Text("Login"),
                    onPressed: () async {
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email.text,
                            password: password.text
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBarLoggedIn);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          ScaffoldMessenger.of(context).showSnackBar(snackBarUserNotFound);
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(snackBarIncorrect);
                          print('Wrong password provided for that user.');
                        }
                      }
                    },
                  ),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountScreen()));
                  },
                  child: Text("new here?"),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

 }