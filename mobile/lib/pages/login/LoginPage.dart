import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/pages/utils/ErrorDialog.dart';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = "";

  @override
  Widget build(BuildContext context) {
    RoomProvider roomProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw Something"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CupertinoTextField(
              placeholder: "User Name",
              onChanged: (v) {
                setState(() {
                  username = v;
                });
              },
            ),
            FlatButton(
              onPressed: username.length == 0
                  ? null
                  : () async {
                      try {
                        await roomProvider.login(username);
                        roomProvider.connect();
                        Navigator.pushReplacementNamed(context, "/home");
                      } catch (err) {
                        showDialog(
                          context: context,
                          builder: (c) => ErrorDialog(
                            title: "Login Error",
                            content: "$err",
                          ),
                        );
                      }
                    },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
