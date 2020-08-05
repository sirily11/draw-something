import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mobile/models/config/config.dart';
import 'package:mobile/models/config/urls.dart';
import 'package:mobile/models/objects/room.dart';
import 'package:mobile/models/objects/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomProvider with ChangeNotifier {
  String baseURL;
  User user;
  Stream roomStream;

  RoomProvider() {
    init();
  }

  init() async {
    if (kIsTest) {
      baseURL = "0.0.0.0";
    } else {
      baseURL = apiURL;
    }
  }

  Future<void> login(String username) async {
    var url = Uri.http(baseURL, loginURL);
    var response = await Dio().post(url.toString(), data: {"name": username});
    var user = User.fromJson(response.data);
    this.user = user;
    var wsUri = Uri(
        scheme: 'ws',
        host: baseURL,
        path: roomWebsocketURL,
        queryParameters: {
          "uuid": user.uuid,
          "name": user.name,
        });
    this.roomStream = WebSocketChannel.connect(
      wsUri,
    ).stream;

    roomStream.listen((event) {
      print(event);
    }, onDone: () {
      print("Websocket is closed");
    }, onError: (err) {
      print("Error: $err");
    });
    notifyListeners();
  }

  Future<void> createRoom(String name) async {
    var url = Uri.http(baseURL, roomURL);
    var response = await Dio().post(url.toString(), data: {"name": name});
  }
}
