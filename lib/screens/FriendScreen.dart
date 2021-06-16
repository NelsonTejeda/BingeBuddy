import 'package:binge_buddy/models/FriendModel.dart';
import 'package:binge_buddy/models/MediaModel.dart';
import 'package:binge_buddy/screens/InCommonScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget{
  @override
  _FriendScreen createState() => _FriendScreen();
}

class _FriendScreen extends State<FriendScreen>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final email = TextEditingController();
  final snackBarUserNull = SnackBar(content: Text('user does not exist'));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    CollectionReference friends = FirebaseFirestore.instance.collection('users/' + auth.currentUser.email + '/friends');
    CollectionReference existingUsers = FirebaseFirestore.instance.collection('users/');
    List<FriendModel> listOfFM = [];

    Future<void> addFriend(String username) {
      // Call the user's CollectionReference to add a new user
      return friends
          .doc(email.text)
          .set({
        'email': email.text,
        'username': username,
        'isFavorite': false
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    Future<void> deleteUser(String email) {
      return friends
          .doc(email)
          .delete()
          .then((value) => print("User Deleted"))
          .catchError((error) => print("Failed to delete user: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Buddies"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              print("adding friend");
              return showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Add Friend"),
                  content: TextField(
                    controller: email,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "your friend's email"
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        existingUsers.doc(email.text).get().then((DocumentSnapshot doc){
                          if(doc.exists){
                            addFriend(doc["username"]);
                            print("this person is real");
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(snackBarUserNull);
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("add"),
                    )
                  ],
                )
              );
            },
          )
        ],
      ),
        body: SafeArea(
          child: Container(
            child: FutureBuilder<QuerySnapshot>(
              future: friends.get(),
              builder: (context,snapshot){
                if(snapshot.hasError){
                  return Center(
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
                      child: Text("Error getting friends!"),
                    ),
                  );
                }
                else if (snapshot.connectionState == ConnectionState.done) {
                  var itr = snapshot.data.docs.iterator;
                  if(snapshot.data.size == 0){
                    return Center(
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 16),
                        child: Text("Need a binge buddy? Click the plus to add one!"),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.size,
                    itemBuilder: (context, int index){
                      Color heartColorOn = Colors.redAccent;
                      Color heartColorOff = Colors.black12;
                      itr.moveNext();
                      listOfFM.add(new FriendModel(itr.current["email"], itr.current["username"], itr.current["isFavorite"]));
                      print("list of friends Model size: ${listOfFM.length}");
                      return ListTile(
                        leading: Icon(Icons.code),
                        trailing: Wrap(
                          spacing: 5,
                          children: [
                            IconButton(
                              icon: Icon(listOfFM[index].isFavorite ? Icons.favorite : Icons.favorite_border_outlined, color: listOfFM[index].isFavorite ? heartColorOn : heartColorOff),
                              onPressed: (){
                                FirebaseFirestore.instance.collection('users/' + auth.currentUser.email + '/friends').doc(listOfFM[index].email).set({
                                  "isFavorite": !listOfFM[index].isFavorite,
                                  "email": listOfFM[index].email,
                                  "username": listOfFM[index].username
                                });
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: (){
                                deleteUser(listOfFM[index].email);
                                listOfFM.removeAt(index);
                                setState(() {});
                              },
                            )
                          ],
                        ),
                        title: Text(itr.current["username"]),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => InCommonScreen(user1: listOfFM[index].email,user2: auth.currentUser.email,)));
                        },
                      );
                    },
                  );
                }
                else{
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        )
    );
  }

}