import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/models/config/urls.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:mobile/models/objects/user.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

extension on Color {
  Map toJson() => {
        "red": this.red.toInt(),
        "blue": this.blue.toInt(),
        "green": this.green.toInt(),
        "opacity": this.opacity.toDouble(),
      };
}

extension on Offset {
  Map toJson() => {
        "dx": this.dx.toDouble(),
        "dy": this.dy.toDouble(),
      };
}

class Line extends BaseMessage {
  List<Offset> offsets;
  Color color;
  User user;

  Line({@required this.color, @required this.offsets, this.user});

  Map toJson() => {
        "offsets": offsets.map((e) => e.toJson()).toList(),
        "color": color.toJson(),
        "user": user.toJson(),
      };

  factory Line.fromJson(Map json) {
    List<Offset> ofs = (json['offsets'] as List)
        ?.map((e) => Offset(e['dx'].toDouble(), e['dy'].toDouble()))
        ?.toList();
    Color c;
    if (json['color'] != null) {
      c = Color.fromRGBO(json['color']['red'], json['color']['green'],
          json['color']['blue'], (json['color']['opacity'] as int).toDouble());
    }

    return Line(
      color: c,
      offsets: ofs,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  @override
  String toString() {
    return "$user - number offsets: ${offsets.length}";
  }
}

class GameProvider with ChangeNotifier {
  List<Line> lines = [];
  List<Line> _removedLines = [];
  Color _drawColor = Colors.indigo;
  Stream gameStream;
  WebSocketChannel webSocketChannel;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<ChatMessage> chat = [];

  Color get drawColor => _drawColor;

  set drawColor(Color color) {
    _drawColor = color;
    notifyListeners();
  }

  void startNewLine(Offset offset) {
    lines.add(
      Line(
        offsets: [offset],
        color: Color.fromRGBO(_drawColor.red, _drawColor.green, _drawColor.blue,
            _drawColor.opacity),
      ),
    );
    _removedLines.clear();
    notifyListeners();
  }

  /// Send message
  void endLine(User user) {
    var line = this.lines.last;
    line.user = user;
    var encodedStr =
        JsonEncoder().convert({"type": "draw", "content": line.toJson()});
    this.webSocketChannel.sink.add(encodedStr);
  }

  void drawLine(Offset offset) {
    lines.last.offsets.add(offset);
    notifyListeners();
  }

  void undo() {
    if (lines.length > 0) {
      var removed = lines.removeLast();
      _removedLines.add(removed);
      notifyListeners();
    }
  }

  void redo() {
    if (_removedLines.length > 0) {
      var restore = _removedLines.removeLast();
      lines.add(restore);
      notifyListeners();
    }
  }

  void clear() {
    lines.clear();
    _removedLines.clear();
    notifyListeners();
  }

  /// Connect to the websocket
  void connect(String baseURL, User user, String room) {
    var uri = Uri(
        scheme: "ws",
        host: baseURL,
        path: gameWebsocketURL,
        queryParameters: {"user": user.uuid, "room": room});

    this.webSocketChannel = WebSocketChannel.connect(uri);
    this.gameStream = this.webSocketChannel.stream.asBroadcastStream();

    var convertedStream = this
        .gameStream
        .map((event) => JsonDecoder().convert(event))
        .map((event) => Message.fromJson(event));

    var chatStream =
        convertedStream.where((event) => event.messageType == MessageType.chat);

    var drawStream =
        convertedStream.where((event) => event.messageType == MessageType.draw);

    drawStream.listen((event) {
      if ((event.message as Line).user.uuid != user.uuid) {
        lines.add(event.message);
      }
      notifyListeners();
    });

    chatStream.listen((event) {
      chat.add(event.message);
      notifyListeners();
      if (chat.length > 2) {
        this.itemScrollController.scrollTo(
              index: chat.length,
              duration: Duration(milliseconds: 300),
            );
      }
    });
  }

  Future<void> sendMessage(String message, User user) async {
    this.webSocketChannel.sink.add(
          JsonEncoder().convert(
            Message(
              messageType: MessageType.chat,
              message: ChatMessage(user: user, message: message),
            ).toJson(),
          ),
        );
    notifyListeners();
  }
}
