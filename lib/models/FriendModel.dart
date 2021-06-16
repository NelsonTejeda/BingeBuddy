import 'package:flutter/material.dart';

class FriendModel{
  String _email;
  String _username;
  bool _isFavorite;
  FriendModel(String email, String username, bool isFavorite){
    this._email = email;
    this._username = username;
    this._isFavorite = isFavorite;
  }

  bool get isFavorite => _isFavorite;

  String get username => _username;

  String get email => _email;
}