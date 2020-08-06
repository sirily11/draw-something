import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:provider/provider.dart';

class WordDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    RoomProvider roomProvider = Provider.of(context);

    return StreamBuilder<RoomMessage>(
        stream: gameProvider.roomStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
              break;
            case ConnectionState.waiting:
              return Text("Loading");
              break;
            case ConnectionState.active:
              var room = snapshot.data;
              if (room.hasStarted) {
                if (room.currentUser == roomProvider.user) {
                  return Text(
                    "Word: ${room.word} | Time: ${room.timeRemaining}",
                  );
                } else {
                  return Text(
                      "${room?.word?.length ?? 0}个字 | Time: ${room.timeRemaining}");
                }
              } else {
                return Text(
                  "已经准备人数: ${room.readyUsers.length}/${room.users.length}",
                );
              }
              break;
            case ConnectionState.done:
              return Text("Disconnected");
              break;
          }

          return Container();
        });
  }
}
