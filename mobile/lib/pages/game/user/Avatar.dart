import 'package:flutter/material.dart';
import 'package:mobile/models/objects/user.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final User currentUser;

  UserAvatar({this.user, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Tooltip(
        message: "${user.name}",
        child: InkWell(
          onTap: () {},
          child: CircleAvatar(
            radius: 25,
            backgroundColor: currentUser?.uuid == user.uuid ? Colors.red : null,
            child: Text(
              "${user.name[0].toUpperCase()}",
            ),
          ),
        ),
      ),
    );
  }
}
