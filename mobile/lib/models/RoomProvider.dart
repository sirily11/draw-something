import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mobile/models/config/config.dart';
import 'package:mobile/models/config/urls.dart';
import 'package:mobile/models/objects/game.dart';
import 'package:mobile/models/objects/room.dart';
import 'package:mobile/models/objects/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomProvider with ChangeNotifier implements Game {
  String baseURL;
  User user;
  Stream roomStream;
  @override
  WebSocketChannel webSocketChannel;

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
    notifyListeners();
  }

  Future<void> createRoom(String name) async {
    var url = Uri.http(baseURL, roomURL);
    var response = await Dio().post(url.toString(), data: {"name": name});
  }

  Future<void> joinRoom(String roomId) async {
    var url = Uri.http(baseURL, joinRoomURL);
    await Dio().post(
      url.toString(),
      queryParameters: {"room": roomId, "user": user.uuid},
    );
  }

  @override
  void closeConnection() {
    this.webSocketChannel?.sink?.close();
  }

  @override
  void connect() async {
    var wsUri = Uri(
        scheme: 'ws',
        host: baseURL,
        path: roomWebsocketURL,
        queryParameters: {
          "uuid": user.uuid,
          "name": user.name,
        });
    this.webSocketChannel = WebSocketChannel.connect(
      wsUri,
    );
    this.roomStream = webSocketChannel.stream.asBroadcastStream();

    notifyListeners();
  }
}
