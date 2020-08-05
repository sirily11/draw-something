import 'package:flutter/material.dart';
import 'package:mobile_new/models/RoomProvider.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      ),
    );
  }
}
