import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/objects/user.dart';

abstract class BaseMessage {
  Map toJson();
}

enum MessageType { draw, chat, system, room, word, command }

class Message {
  BaseMessage message;
  List<BaseMessage> messages;
  MessageType messageType;

  Message({this.message, this.messageType, this.messages});

  factory Message.fromJson(Map json) {
    switch (json['type']) {
      case "chat":
        return Message(
            message: ChatMessage.fromJson(json['content']),
            messageType: MessageType.chat);

      case "room":
        return Message(
          messageType: MessageType.room,
          message: RoomMessage.fromJson(json['content']),
        );

      case "word":
        return Message(
          messageType: MessageType.word,
          message: WordMessage.fromJson(json['content']),
        );

      case "command":
        return Message(
          messageType: MessageType.command,
          message: Command.fromJson(json['content']),
        );

      default:
        return Message(
          message:
              json['content'] != null ? Line.fromJson(json['content']) : null,
          messageType: MessageType.draw,
        );
    }
  }

  Map toJson() {
    String type;

    switch (messageType) {
      case MessageType.draw:
        type = "draw";
        break;
      case MessageType.chat:
        type = "chat";
        break;
      case MessageType.system:
        type = "system";
        break;
      case MessageType.room:
        type = "room";
        break;
      case MessageType.word:
        type = "word";
        break;
      case MessageType.command:
        type = "command";
        break;
    }

    return {
      "type": type,
      "content": message.toJson(),
    };
  }
}

class Command extends BaseMessage {
  Command({
    this.command,
    this.user,
  });

  String command;
  User user;

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        command: json['command'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );

  Map<String, dynamic> toJson() => {
        "command": command,
        "user": user,
      };
}

class SystemMessage extends BaseMessage {
  SystemMessage({
    this.message,
  });

  String message;

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}

class RoomMessage extends BaseMessage {
  RoomMessage({
    this.hasStarted,
    this.name,
    this.timeRemaining,
    this.users,
    this.word,
    this.currentUser,
    this.readyUsers,
  });

  bool hasStarted;
  String name;
  double timeRemaining;
  List<User> users;
  List<User> readyUsers;
  User currentUser;
  String word;

  factory RoomMessage.fromJson(Map<String, dynamic> json) => RoomMessage(
        hasStarted: json["hasStarted"],
        name: json["name"],
        timeRemaining: json["timeRemaining"].toDouble(),
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        readyUsers:
            List<User>.from(json["readyUsers"].map((x) => User.fromJson(x))),
        word: json["word"] == null ? null : json["word"],
        currentUser: json['currentUser'] != null
            ? User.fromJson(json['currentUser'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "hasStarted": hasStarted,
        "name": name,
        "timeRemaining": timeRemaining,
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
        "readyUsers": List<dynamic>.from(readyUsers.map((x) => x.toJson())),
        "word": word == null ? null : word,
      };
}

class WordMessage extends BaseMessage {
  WordMessage({
    this.hint,
    this.word,
  });

  String hint;
  String word;

  factory WordMessage.fromJson(Map<String, dynamic> json) => WordMessage(
        hint: json["hint"],
        word: json["word"],
      );

  Map<String, dynamic> toJson() => {
        "hint": hint,
        "word": word,
      };
}

class ChatMessage extends BaseMessage {
  ChatMessage({
    this.message,
    this.user,
  });

  String message;
  User user;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        message: json["message"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "user": user.toJson(),
      };
}
