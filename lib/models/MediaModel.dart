import 'package:flutter/material.dart';

class MediaModel{
  //movies private variables
  String _moviePosterPath;
  int _movieId;
  String _movieOverview;
  String _releaseDate;
  String _title;
  double _movieRating;

  //TV private variables
  String _firstAirDate;
  double _tvRating;
  String _name;
  int _tvId;
  String _tvOverview;
  String _tvPosterPath;

  //variables used for both;
  bool isMovie;

  MediaModel.movies(int movieId, String title, String posterPath, String releaseDate, double movieRating, String movieOverview){
    _movieId = movieId;
    _title = title;
    _moviePosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;
    _releaseDate = releaseDate;
    _movieRating = movieRating;
    _movieOverview = movieOverview;
    isMovie = true;
  }
  MediaModel.tv(int tvId, String name, String posterPath, String firstAirDate, double tvRating, String tvOverview){
    _tvId = tvId;
    _name = name;
    _tvPosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;
    _firstAirDate = firstAirDate;
    _tvRating = tvRating;
    _tvOverview = tvOverview;
    isMovie = false;
  }

  factory MediaModel.moviesFromJson(final json, int num){
    final results = json["results"][num];
    return MediaModel.movies(results["id"], results["title"], results["poster_path"], results["release_date"], results["vote_average"], results["overview"]);
  }

  factory MediaModel.showsFromJson(final json, int num){
    final results = json["results"][num];
    return MediaModel.tv(results["id"], results["name"], results["poster_path"], results["first_air_date"], results["vote_average"], results["overview"]);
  }


  //tv setters

  String get tvPosterPath => _tvPosterPath;

  String get tvOverview => _tvOverview;

  int get tvId => _tvId;

  String get name => _name;

  double get tvRating => _tvRating;

  String get firstAirDate => _firstAirDate;

  //movie getters

  double get movieRating => _movieRating;

  String get title => _title;

  String get releaseDate => _releaseDate;

  String get movieOverview => _movieOverview;

  int get movieId => _movieId;

  String get moviePosterPath => _moviePosterPath;

}