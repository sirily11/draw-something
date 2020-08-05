import 'dart:html';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mobile_new/models/config/config.dart';
import 'package:mobile_new/models/config/urls.dart';
import 'package:mobile_new/models/objects/user.dart';

class RoomProvider with ChangeNotifier {
  String baseURL;
  User user;

  RoomProvider() {
    init();
  }

  init() async {
    if (kIsTest) {
      baseURL = "http://0.0.0.0";
    } else {
      baseURL = apiURL;
    }
  }

  Future<void> login(String username) async {
    var url = "$baseURL$loginURL";
    var response = await Dio().post(url, data: {"name": username});
    var user = User.fromJson(response.data);
    this.user = user;

    // var stream = WebSocketChannel.connect(Uri.http(baseURL, roomWebsocketURL))
    //     .stream
    //     .asBroadcastStream();
    notifyListeners();
  }

  Future<void> createRoom(String name) async {
    var url = "$baseURL$roomURL";
    var response = await Dio().post(url, data: {"name": name});
  }
}
