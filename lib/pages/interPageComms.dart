import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart';
class UserData extends ChangeNotifier {
  ObjectId _username = new ObjectId();
  ObjectId get username => _username; 

  void setUsername(ObjectId value) {
    _username = value;
    notifyListeners();
  }
}