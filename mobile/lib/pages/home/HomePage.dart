import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/models/objects/room.dart';
import 'package:mobile/pages/game/GamePage.dart';
import 'package:mobile/pages/home/createRoom/CreateRoomDialog.dart';
import 'package:mobile/pages/utils/ErrorDialog.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  @override
  void initState() {
    RoomProvider roomProvider = Provider.of(context, listen: false);
    if (roomProvider.user == null) {
      Navigator.pushNamed(context, "/");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RoomProvider roomProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Room"),
        actions: [
          IconButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (c) => CreateRoomDialog(),
              );
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: roomProvider.roomStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: FlatButton(
                    onPressed: () {
                      roomProvider.connect();
                    },
                    child: Text("Reconnect"),
                  ),
                );
              }

              List<Room> room = (JsonDecoder().convert(snapshot.data) as List)
                  .map((r) => Room.fromJson(r))
                  .toList();
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: room.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        GameProvider gameProvider =
                            Provider.of(context, listen: false);
                        await roomProvider.joinRoom(room[index].room);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => GamePage(room: room[index].room),
                          ),
                        );
                        gameProvider.closeConnection();
                      } catch (err) {
                        await showDialog(
                          context: context,
                          builder: (c) => ErrorDialog(
                            title: "Cannot join the room",
                            content: "$err",
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    title: Text("Room"),
                    subtitle: Text("${room[index].name}"),
                    trailing:
                        Text("Number of users: ${room[index].users.length}"),
                  );
                },
              );
            },
          ),
          if (isLoading)
            Align(
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
