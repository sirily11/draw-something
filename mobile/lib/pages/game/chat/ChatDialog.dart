import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);

    return Positioned(
      height: 300,
      width: 400,
      right: 60,
      bottom: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 200,
            height: 200,
            child: ScrollablePositionedList.builder(
                itemCount: gameProvider.chat.length,
                itemPositionsListener: gameProvider.itemPositionsListener,
                itemScrollController: gameProvider.itemScrollController,
                itemBuilder: (context, index) {
                  if (index < 0) {
                    return Container();
                  }
                  var chat = gameProvider.chat[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 80,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${chat.user.name}: ${chat.message}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 20,
          ),
          CupertinoTextField(
            focusNode: focusNode,
            controller: textEditingController,
            autofocus: true,
            onSubmitted: (v) async {
              await gameProvider.sendMessage(v);
              textEditingController.clear();
              FocusScope.of(context).requestFocus(focusNode);
            },
            placeholder: "Message...",
          )
        ],
      ),
    );
  }
}
