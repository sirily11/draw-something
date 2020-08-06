import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/objects/chat.dart';
import 'package:provider/provider.dart';

class HintDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);

    return StreamBuilder<WordMessage>(
        stream: gameProvider.wordStream,
        builder: (context, snapshot) {
          var wordMessage = snapshot.data;
          bool hasData = snapshot.hasData;

          return AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: hasData ? 10 : -100,
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: min(MediaQuery.of(context).size.width, 400),
                  color: Colors.blue,
                  child: hasData
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(
                                "${wordMessage?.word}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "${wordMessage?.hint}",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 50,
                          width: 100,
                        ),
                ),
              ),
            ),
          );
        });
  }
}
