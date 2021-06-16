import 'dart:convert';
import 'package:binge_buddy/models/SecureStorageObject.dart';
import 'package:binge_buddy/secureValues/Secure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge_buddy/models/MediaUIModel.dart';
import 'package:flutter/material.dart';
import 'package:binge_buddy/models/MediaModel.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'InfoScreen.dart';


class MoviesScreen extends StatefulWidget{
  @override
  _MoviesScreen createState() => _MoviesScreen();
}

class _MoviesScreen extends State<MoviesScreen> with TickerProviderStateMixin, WidgetsBindingObserver{
  List<Widget> listOfMedia;
  List<MediaModel> listOfMediaObjects;
  PageController controller;
  int page;
  bool heartVis;

  Animation _heartAnimation;
  AnimationController _heartAnimationController;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> addMediaModel(MediaModel m) {
    // Call the user's CollectionReference to add a new user
    CollectionReference db = FirebaseFirestore.instance.collection('users/' + auth.currentUser.email + "/mediaLiked");
    return db
        .doc("${m.isMovie ? m.movieId : m.tvId}")
        .set({
      'id': m.isMovie ? m.movieId : m.tvId,
      'title': m.isMovie ? m.title : m.name,
      'posterPath': m.isMovie ? m.moviePosterPath : m.tvPosterPath,
      'releaseDate' : m.isMovie ? m.releaseDate : m.firstAirDate,
      'rating': m.isMovie ? m.movieRating : m.tvRating,
      'overview': m.isMovie ? m.movieOverview : m.tvOverview,
      'isMovie' : m.isMovie
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }




  Future<List<MediaModel>> getMovies() async{
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/trending/movie/week?api_key=${Secure.APIKEY}" + "&page=$page"));
    final responseTv =  await http.get(Uri.parse("https://api.themoviedb.org/3/trending/tv/week?api_key=${Secure.APIKEY}" + "&page=$page"));

    if(response.statusCode == 200){
      final jsonMovies = jsonDecode(response.body);
      final jsonShows = jsonDecode(responseTv.body);

      List<MediaModel> allMovies = [];

      for(int i = 0; i < jsonMovies["results"].length; i++){
        allMovies.add(MediaModel.moviesFromJson(jsonMovies, i));
        allMovies.add(MediaModel.showsFromJson(jsonShows, i));
      }

      return allMovies;
    }else{
      setState(() {});
      getMovies();
    }

  }


  List<Widget> getMediaModels(List<MediaModel> models){
    List<Widget> ans = [];
    for(int i = 0; i < models.length; i++){
      ans.add(
          new Image.network(
            models[i].isMovie ? models[i].moviePosterPath : models[i].tvPosterPath,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          )
      );
    }
    return ans;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.inactive || state == AppLifecycleState.detached){
      return;
    }
    final isBackground = state == AppLifecycleState.paused;

    if(isBackground){
      SecureStorageObject.setObject("page", page.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPageNumber();
    });

    listOfMedia = [];
    listOfMediaObjects = [];
    controller = PageController(initialPage: 0,viewportFraction: 0.99);
    heartVis = false;

    _heartAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _heartAnimation = Tween(begin: 100.0, end: 200.0).animate(CurvedAnimation(
        curve: Curves.bounceOut, parent: _heartAnimationController));

    _heartAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        heartVis = false;
        _heartAnimationController.reset();
        setState(() {});
      }
    });

  }

  void _getPageNumber() async{
    SecureStorageObject.getObject("page").then((value) {
      if(value == null || value == ""){
        page = 1;
      }
      else{
        page = int.parse(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => InfoScreen(mediaPassed: listOfMediaObjects[controller.page.round()])));
            },
            onDoubleTap: (){
              //TODO: send to database
              addMediaModel(listOfMediaObjects[controller.page.round()]);
              heartVis = true;
              setState(() {});
              _heartAnimationController.forward();
            },
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: controller,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (pos){
                      if(pos == listOfMedia.length - 5){
                        page++;
                        setState(() {});
                      }
                    },
                    itemBuilder: (context, index){
                      return FutureBuilder(
                        future: getMovies(),
                        builder: (context,snapshot){
                          if(snapshot.hasError){
                            return Text(snapshot.error.toString());
                          }
                          if(snapshot.hasData){
                            if(index == 0){
                              listOfMedia = getMediaModels(snapshot.data);
                              listOfMediaObjects = snapshot.data;
                            }
                            if(index == listOfMedia.length - 1){
                              listOfMedia.addAll(getMediaModels(snapshot.data));
                              listOfMediaObjects.addAll(snapshot.data);
                            }
                            print(listOfMedia.length);
                            print("Index: $index");
                            try{
                              return listOfMedia[index];
                            }catch(e){
                              return Container(
                                color: Colors.amber,
                                child: Text("error loading image"),
                              );
                            }
                          }
                          else{
                            return CircularProgressIndicator();
                          }
                        },
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: heartVis,
                  child: Container(
                    child: AnimatedBuilder(
                      animation: _heartAnimationController,
                      builder: (context,child){
                        return Center(
                          child: Container(
                            child: Center(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: _heartAnimation.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Container(
                //   alignment: Alignment.centerRight,
                //   child: Icon(
                //     Icons.favorite,
                //     color: Colors.redAccent,
                //   ),
                // )
              ],
            ),
          )
        )
    );
  }

}





