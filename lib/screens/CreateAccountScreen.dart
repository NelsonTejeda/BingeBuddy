
import 'package:binge_buddy/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountScreen extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController username = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  final snackBarAccountMade = SnackBar(content: Text('Account Created!'));
  final snackBarWeakPass = SnackBar(content: Text('The password provided is too weak.'));
  final snackBarAccountExist = SnackBar(content: Text('The account already exists for that email.'));
  final snackBarShortPass = SnackBar(content: Text('Password must be at least six characters.'));

  @override
  Widget build(BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    Future<void> addUser(String currentUserUID) {
      return users
          .doc(email.text)
          .set({
        'username': username.text,
        'email': email.text
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Container(
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
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'username'
                  ),
                  controller: username,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10,bottom: 10),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'email'
                    ),
                    controller: email,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'password'
                  ),
                  controller: password,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        FocusScope.of(context).unfocus();
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email.text,
                            password: password.text
                        ).then((value) => addUser(FirebaseAuth.instance.currentUser.uid));
                        //await addUser(FirebaseAuth.instance.currentUser.uid);
                        ScaffoldMessenger.of(context).showSnackBar(snackBarAccountMade);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          ScaffoldMessenger.of(context).showSnackBar(snackBarWeakPass);
                          print('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(snackBarAccountExist);
                          print('The account already exists for that email.');
                        }
                        else if(password.text.length == 0){
                          ScaffoldMessenger.of(context).showSnackBar(snackBarShortPass);
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text("sign up!"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
