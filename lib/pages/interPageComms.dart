import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart';
class UserData extends ChangeNotifier {
  ObjectId _id = new ObjectId();
  ObjectId get id => _id;

  void setId(ObjectId value) {
    _id = value;
    notifyListeners();
  }
}