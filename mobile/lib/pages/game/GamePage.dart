import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:mobile/pages/game/chat/ChatDialog.dart';
import 'package:mobile/pages/game/tool/ToolButtons.dart';
import 'package:mobile/pages/game/draw/DrawBoard.dart';
import 'package:mobile/pages/game/user/AvatarList.dart';
import 'package:mobile/pages/game/word/HintDisplay.dart';
import 'package:mobile/pages/game/word/WordDisplay.dart';
import 'package:mobile/pages/utils/ErrorDialog.dart';
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

    gameProvider.connect(
      baseURL: roomProvider.baseURL,
      user: roomProvider.user,
      room: widget.room,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    RoomProvider roomProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: WordDisplay(),
        actions: [StartGameButton(room: widget.room)],
      ),
      body: StreamBuilder<RoomMessage>(
          stream: gameProvider.roomStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: FlatButton(
                  onPressed: () {
                    gameProvider.connect(
                      baseURL: roomProvider.baseURL,
                      user: roomProvider.user,
                      room: widget.room,
                    );
                  },
                  child: Text("Reconnect"),
                ),
              );
            }

            return Stack(
              children: [
                DrawBoard(),
                ToolButtons(),
                ChatList(),
                AvatarList(),
                HintDisplay(),
              ],
            );
          }),
    );
  }
}

class StartGameButton extends StatelessWidget {
  final String room;

  const StartGameButton({
    Key key,
    this.room,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    RoomProvider roomProvider = Provider.of(context);
    return StreamBuilder<RoomMessage>(
        stream: gameProvider.roomStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          RoomMessage room = snapshot.data;
          bool isReady = room.readyUsers.contains(roomProvider.user);

          if (room.hasStarted) {
            return Container();
          }

          if (isReady) {
            return FlatButton(
              onPressed: () async {
                try {
                  await gameProvider.notReady(
                    room: this.room,
                  );
                } catch (err) {
                  showDialog(
                    context: context,
                    builder: (c) => ErrorDialog(
                      title: "Cannot not ready",
                      content: "$err",
                    ),
                  );
                }
              },
              child: Text(
                "取消准备",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return FlatButton(
              onPressed: () async {
                try {
                  await gameProvider.ready(
                    room: this.room,
                  );
                } catch (err) {
                  showDialog(
                    context: context,
                    builder: (c) => ErrorDialog(
                      title: "Cannot ready",
                      content: "$err",
                    ),
                  );
                }
              },
              child: Text(
                "准备",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        });
  }
}
