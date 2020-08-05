import 'package:mobile/models/objects/user.dart';

class Room {
  Room({
    this.hasStarted,
    this.name,
    this.timeRemaining,
    this.users,
    this.room,
  });

  bool hasStarted;
  String name;
  double timeRemaining;
  List<User> users;
  String room;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        hasStarted: json["hasStarted"],
        name: json["name"],
        timeRemaining: json["timeRemaining"].toDouble(),
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        room: json['room'],
      );

  Map<String, dynamic> toJson() => {
        "hasStarted": hasStarted,
        "name": name,
        "timeRemaining": timeRemaining,
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
        "room": room,
      };
}
