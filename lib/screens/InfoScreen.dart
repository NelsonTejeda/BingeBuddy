import 'dart:convert';

import 'package:binge_buddy/models/MediaModel.dart';
import 'package:binge_buddy/secureValues/Secure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;

import '../models/MediaModel.dart';
import '../models/ProviderModel.dart';

class InfoScreen extends StatefulWidget{
  final MediaModel mediaPassed;
  InfoScreen({Key key, @required this.mediaPassed}) : super(key: key);
  @override
  _InfoScreen createState() => _InfoScreen();
}

class _InfoScreen extends State<InfoScreen>{

  //youtube key
  static String key = "AIzaSyBvRp9zsHPHWiD1-aY2-1fW5_5KIgvmIXU";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    RatingBar ratingBar = RatingBar.builder(
      initialRating: widget.mediaPassed.isMovie ? widget.mediaPassed.movieRating / 2 : widget.mediaPassed.tvRating / 2,
      minRating: widget.mediaPassed.isMovie ? widget.mediaPassed.movieRating / 2 : widget.mediaPassed.tvRating / 2,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
      maxRating: 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaPassed.isMovie ? widget.mediaPassed.title : widget.mediaPassed.name),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),

      ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                FutureBuilder(
                  future: getMovieTvVideo(widget.mediaPassed),
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      YoutubePlayerController controller = YoutubePlayerController(initialVideoId: snapshot.data);
                      return YoutubePlayerIFrame(controller: controller, aspectRatio: 16 / 9,);
                    }
                    else if(snapshot.hasError){
                      return Text(snapshot.error.toString());
                    }
                    else{
                      return CircularProgressIndicator();
                    }
                  },
                ),
                Text(widget.mediaPassed.isMovie ? widget.mediaPassed.movieOverview : widget.mediaPassed.tvOverview),
                ratingBar,
                Text("${widget.mediaPassed.isMovie ? widget.mediaPassed.movieRating / 2 : widget.mediaPassed.tvRating / 2}"),
                SizedBox(height: 20,),
                Text("All providers:"),
                FutureBuilder<List<ProviderModel>>(
                  future: getProviders(widget.mediaPassed),
                  builder: (context, snapshot){
                    if(snapshot.data == null || snapshot.data.length == 0){
                      return Text("no providers");
                    }
                    if(snapshot.hasError){
                      return Text(snapshot.error.toString());
                    }
                    else if(snapshot.hasData){
                      return Container(
                        child: Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context,index){
                              return Padding(
                                padding: EdgeInsets.all(15),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    snapshot.data[index].logoPath,
                                  ) ,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    else{
                      return CircularProgressIndicator();
                    }
                  },
                )
              ],
            )
          ),
        )
    );
  }

}

Future<String> getMovieTvVideo(MediaModel m) async{
  if(m.isMovie){
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/movie/${m.movieId}/videos?api_key=${Secure.APIKEY}&language=en-US"));
    if(response.statusCode == 200){
      final jsonVideo = jsonDecode(response.body);
      return jsonVideo["results"][0]["key"];
    }
    else{
      return "";
    }
  }
  else{
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/tv/${m.tvId}/videos?api_key=${Secure.APIKEY}&language=en-US"));
    if(response.statusCode == 200){
      final jsonVideo = jsonDecode(response.body);
      return jsonVideo["results"][0]["key"];
    }
    else{
      return "";
    }
  }

}

Future<List<ProviderModel>> getProviders(MediaModel m) async{
  List<ProviderModel> listOfProviders = [];
  if(m.isMovie){
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/movie/${m.movieId}/watch/providers?api_key=${Secure.APIKEY}"));
    if(response.statusCode == 200){
      try{
        final proJson = jsonDecode(response.body);
        final flateRate = proJson["results"]["US"]["flatrate"];
        for(var fr in flateRate){
          listOfProviders.add(new ProviderModel(fr["logo_path"], fr["provider_id"], fr["provider_name"]));
        }
      }catch(e){
        print("no flatrates: ${e.toString()}");
      }
      try{
        final proJson = jsonDecode(response.body);
        final rent = proJson["results"]["US"]["rent"];
        for(var r in rent){
          listOfProviders.add(new ProviderModel(r["logo_path"], r["provider_id"], r["provider_name"]));
        }
      }catch(e){
        print("no rents: ${e.toString()}");
      }
      try{
        final proJson = jsonDecode(response.body);
        final buy = proJson["results"]["US"]["buy"];
        for(var b in buy){
          listOfProviders.add(new ProviderModel(b["logo_path"], b["provider_id"], b["provider_name"]));
        }
      }catch(e){
        print("no flatrates: ${e.toString()}");
      }
    }
  }
  else{
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/tv/${m.tvId}/watch/providers?api_key=${Secure.APIKEY}"));
    if(response.statusCode == 200){
      try{
        final proJson = jsonDecode(response.body);
        final flateRate = proJson["results"]["US"]["flatrate"];
        for(var fr in flateRate){
          listOfProviders.add(new ProviderModel(fr["logo_path"], fr["provider_id"], fr["provider_name"]));
        }
      }catch(e){
        print("no flatrates: ${e.toString()}");
      }
      try{
        final proJson = jsonDecode(response.body);
        final rent = proJson["results"]["US"]["rent"];
        for(var r in rent){
          listOfProviders.add(new ProviderModel(r["logo_path"], r["provider_id"], r["provider_name"]));
        }
      }catch(e){
        print("no rents: ${e.toString()}");
      }
      try{
        final proJson = jsonDecode(response.body);
        final buy = proJson["results"]["US"]["buy"];
        for(var b in buy){
          listOfProviders.add(new ProviderModel(b["logo_path"], b["provider_id"], b["provider_name"]));
        }
      }catch(e){
        print("no flatrates: ${e.toString()}");
      }
    }
  }
  return listOfProviders;
}
