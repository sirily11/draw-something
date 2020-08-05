import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:provider/provider.dart';

import 'ColorPickerDialog.dart';

class ToolButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    return Positioned(
      bottom: 100,
      left: 40,
      child: Column(
        children: [
          FloatingActionButton(
            tooltip: "Redo",
            heroTag: "Redo",
            onPressed: () {
              gameProvider.redo();
            },
            child: Icon(Icons.redo),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            tooltip: "Undo",
            heroTag: "Undo",
            onPressed: () {
              gameProvider.undo();
            },
            child: Icon(Icons.undo),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            tooltip: "Clear",
            heroTag: "Clear",
            onPressed: () {
              gameProvider.clear();
            },
            child: Icon(Icons.clear),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            tooltip: "Edit Color",
            heroTag: "Edit",
            onPressed: () async {
              Color color = await showDialog(
                context: context,
                builder: (c) => ColorPickerDialog(
                  initColor: gameProvider.drawColor,
                ),
              );
              if (color != null) {
                gameProvider.drawColor = color;
              }
            },
            child: Icon(
              Icons.edit,
            ),
          ),
        ],
      ),
    );
  }
}
