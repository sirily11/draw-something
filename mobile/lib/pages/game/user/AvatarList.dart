import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:mobile/pages/game/user/Avatar.dart';
import 'package:provider/provider.dart';

class AvatarList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    return Positioned(
      right: 0,
      width: 70,
      child: StreamBuilder<RoomMessage>(
          stream: gameProvider.roomStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            var users = snapshot.data.users;
            var currentUser = snapshot.data.currentUser;

            return SingleChildScrollView(
              child: Column(
                children: [
                  for (var user in users)
                    UserAvatar(
                      user: user,
                      currentUser: currentUser,
                    ),
                ],
              ),
            );
          }),
    );
  }
}
