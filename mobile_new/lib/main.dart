import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/RoomProvider.dart';
import 'pages/login/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        routes: {
          "/": (c) => LoginPage(),
        },
        initialRoute: "/",
      ),
    );
  }
}
