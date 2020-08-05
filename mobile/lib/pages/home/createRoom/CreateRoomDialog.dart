import 'package:flutter/material.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/pages/utils/ErrorDialog.dart';

import 'package:provider/provider.dart';

class CreateRoomDialog extends StatefulWidget {
  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    RoomProvider roomProvider = Provider.of(context);
    return AlertDialog(
      title: Text("Create Room"),
      content: TextField(
        decoration: InputDecoration(labelText: "Room Name"),
        onChanged: (v) {
          setState(() {
            name = v;
          });
        },
      ),
      actions: [
        FlatButton(
          onPressed: name.length == 0
              ? null
              : () async {
                  try {
                    await roomProvider.createRoom(name);
                    Navigator.pop(context);
                  } catch (err) {
                    await showDialog(
                      context: context,
                      builder: (c) => ErrorDialog(
                        title: "Cannot Create Room",
                        content: "$err",
                      ),
                    );
                  }
                },
          child: Text("Create"),
        )
      ],
    );
  }
}
