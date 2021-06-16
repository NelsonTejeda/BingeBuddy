import 'package:binge_buddy/models/MediaModel.dart';
import 'package:binge_buddy/screens/InfoScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class InCommonScreen extends StatelessWidget {
  final String user1;
  final String user2;

  const InCommonScreen({Key key, @required this.user1,@required this.user2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies/TV in common"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<MediaModel>>(
          future: getComparison(user1, user2),
          builder: (context,snapshot){
            if(snapshot.data == null || snapshot.data.length == 0){
              return Text("This is empty");
            }
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }
            else if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data.length,
                padding: EdgeInsets.all(0.8),
                itemBuilder: (context,index){
                  return ListTile(
                    trailing: Wrap(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amberAccent,
                        ),
                        Text("${snapshot.data[index].isMovie ? snapshot.data[index].movieRating : snapshot.data[index].tvRating}")
                      ],
                    ),
                    leading: Text(snapshot.data[index].isMovie ? snapshot.data[index].title : snapshot.data[index].name),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoScreen(mediaPassed: snapshot.data[index])));
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
    );
  }
}


Future<List<MediaModel>> getComparison(String u1, String u2) async{
  List<MediaModel> listOfMedia = [];
  List<MediaModel> common = [];
  await FirebaseFirestore.instance.collection('users/' + u1 + '/mediaLiked').get().then((QuerySnapshot qs){
    qs.docs.forEach((document){
      listOfMedia.add(document["isMovie"] ? MediaModel.movies(document["id"], document["title"], document["posterPath"], document["releaseDate"], document["rating"], document["overview"]) :
      MediaModel.tv(document["id"], document["title"], document["posterPath"], document["releaseDate"], document["rating"], document["overview"]));
    });
  }).then((value) => FirebaseFirestore.instance.collection('users/' + u2 + '/mediaLiked').get().then((QuerySnapshot querySnapshot){
    List<int> indexes = [];
    print("list of Media size: ${listOfMedia.length}");
    print(querySnapshot.docs.toString());
    querySnapshot.docs.forEach((element) {
      int c = 0;
      for(int i = 0; i < listOfMedia.length; i++){
        if(listOfMedia[i].isMovie ? listOfMedia[i].title == element["title"] : listOfMedia[i].name == element["title"]){
          common.add(listOfMedia[i]);
        }
      }
    });
  }));
  return common;
}
//listOfMedia.add(document["isMovie"] ? MediaModel.movies(document["id"], document["title"], document["posterPath"], document["releaseDate"], document["rating"], document["overview"]) :
//MediaModel.tv(document["id"], document["title"], document["posterPath"], document["releaseDate"], document["rating"], document["overview"]));