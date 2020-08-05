import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;

  ErrorDialog({@required this.title, @required this.content});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("$title"),
      content: Text("$content"),
      actions: [
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
