import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:mobile/pages/login/LoginPage.dart';
import 'package:provider/provider.dart';

import 'pages/home/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => RoomProvider(),
        ),
        ChangeNotifierProvider(
          create: (c) => GameProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          "/": (c) => LoginPage(),
          '/home': (c) => HomePage(),
        },
        initialRoute: "/",
      ),
    );
  }
}
