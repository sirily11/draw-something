import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/pages/game/chat/ChatDialog.dart';
import 'package:mobile/pages/game/tool/ToolButtons.dart';
import 'package:mobile/pages/game/draw/DrawBoard.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  final String room;

  GamePage({@required this.room});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    RoomProvider roomProvider = Provider.of(context, listen: false);
    GameProvider gameProvider = Provider.of(context, listen: false);

    gameProvider.connect(roomProvider.baseURL, roomProvider.user, widget.room);


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          DrawBoard(),
          ToolButtons(),
          ChatList(),
        ],
      ),
    );
  }
}
