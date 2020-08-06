import 'package:mobile/models/objects/user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class Game {
  String baseURL;
  User user;
  WebSocketChannel webSocketChannel;

  /// open a websocket connection
  void connect();

  /// close the websocket connection
  void closeConnection();
}
