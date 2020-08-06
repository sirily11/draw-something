import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/config/urls.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:mobile/models/objects/game.dart';
import 'package:mobile/models/objects/user.dart';
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

class GameProvider with ChangeNotifier implements Game {
  @override
  User user;
  @override
  String baseURL;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<Line> lines = [];
  List<Line> _removedLines = [];
  Color _drawColor = Colors.indigo;
  bool canDraw = true;
  Stream gameStream;

  /// A stream contains room info
  Stream<RoomMessage> roomStream;

  /// A stream contains word info
  Stream<WordMessage> wordStream;

  List<ChatMessage> chat = [];

  @override
  WebSocketChannel webSocketChannel;

  Color get drawColor => _drawColor;

  set drawColor(Color color) {
    _drawColor = color;
    notifyListeners();
  }

  void startNewLine(Offset offset) {
    if (canDraw) {
      lines.add(
        Line(
          offsets: [offset],
          color: Color.fromRGBO(_drawColor.red, _drawColor.green,
              _drawColor.blue, _drawColor.opacity),
        ),
      );
      _removedLines.clear();
      notifyListeners();
    }
  }

  /// Send message
  void endLine() {
    if (canDraw) {
      var line = this.lines.last;
      line.user = user;
      var encodedStr =
          JsonEncoder().convert({"type": "draw", "content": line.toJson()});
      this.webSocketChannel.sink.add(encodedStr);
    }
  }

  /// Draw line with given offset
  void drawLine(Offset offset) {
    if (canDraw) {
      lines.last.offsets.add(offset);
      notifyListeners();
    }
  }

  /// Undo command
  void undo() {
    if (canDraw) {
      _undo();
      _sendCommand(Command(command: "undo"));
    }
  }

  void _undo() {
    if (lines.length > 0) {
      var removed = lines.removeLast();
      _removedLines.add(removed);
      notifyListeners();
    }
  }

  /// Redo command
  void redo() {
    if (canDraw) {
      _redo();
      _sendCommand(Command(command: "redo"));
    }
  }

  void _redo() {
    if (_removedLines.length > 0) {
      var restore = _removedLines.removeLast();
      lines.add(restore);
      notifyListeners();
    }
  }

  /// Clear all drawing
  void clear() {
    if (canDraw) {
      _clear();
      _sendCommand(Command(command: "clear"));
    }
  }

  void _clear() {
    lines.clear();
    _removedLines.clear();
    notifyListeners();
  }

  void _sendCommand(Command command) {
    var str = JsonEncoder().convert(
      Message(message: command, messageType: MessageType.command).toJson(),
    );

    this.webSocketChannel?.sink?.add(str);
  }

  /// Connect to the websocket
  void connect({
    @required String baseURL,
    @required User user,
    @required String room,
  }) {
    this.baseURL = baseURL;
    this.user = user;
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

    this.roomStream = convertedStream
        .where((event) => event.messageType == MessageType.room)
        .map((event) => event.message as RoomMessage)
        .asBroadcastStream();

    this.wordStream = convertedStream
        .where((event) => event.messageType == MessageType.word)
        .map((event) => event.message as WordMessage)
        .asBroadcastStream();

    var commandStream = convertedStream
        .where((event) => event.messageType == MessageType.command)
        .map((event) => event.message as Command)
        .asBroadcastStream();

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

    roomStream.listen((event) {
      canDraw = true;
      if (event.hasStarted) {
        if (event.currentUser != user) {
          canDraw = false;
          notifyListeners();
        }
      }
    });

    commandStream.listen((event) {
      switch (event.command) {
        case "clear":
          _clear();
          break;
        case "redo":
          _redo();
          break;
        case "undo":
          _undo();
          break;
      }
    });
  }

  /// Send chat messages
  Future<void> sendMessage(String message) async {
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

  /// Press button to get in the ready position
  Future<void> ready({
    @required String room,
  }) async {
    var uri = Uri.http(baseURL, startGameURL);
    await Dio().post(uri.toString(),
        queryParameters: {"user": user.uuid, "room": room});
  }

  /// Press button to get in the unready position
  Future<void> notReady({
    @required String room,
  }) async {
    var uri = Uri.http(baseURL, startGameURL);
    await Dio().delete(uri.toString(),
        queryParameters: {"user": user.uuid, "room": room});
  }

  @override
  void closeConnection() {
    this.webSocketChannel?.sink?.close();
  }
}
