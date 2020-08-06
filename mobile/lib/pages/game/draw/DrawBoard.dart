import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/models/GameProvider.dart';
import 'package:mobile/models/RoomProvider.dart';
import 'package:provider/provider.dart';

class DrawBoard extends StatefulWidget {
  @override
  _DrawBoardState createState() => _DrawBoardState();
}

class _DrawBoardState extends State<DrawBoard> {
  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of(context);
    return GestureDetector(
        onTap: () {},
        onPanUpdate: (details) {
          gameProvider.drawLine(details.localPosition);
        },
        onPanDown: (details) {
          gameProvider.startNewLine(details.localPosition);
        },
        onPanEnd: (details) {
          gameProvider.endLine();
        },
        child: LayoutBuilder(
          builder: (context, cons) {
            return Container(
              height: cons.maxHeight,
              width: cons.maxWidth,
              child: CustomPaint(
                painter: DrawPainter(
                  lines: gameProvider.lines,
                ),
              ),
            );
          },
        ));
  }
}

class DrawPainter extends CustomPainter {
  final List<Line> lines;

  DrawPainter({
    this.lines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..color = line.color;
      final path = Path()..moveTo(line.offsets[0].dx, line.offsets[0].dy);
      for (var i = 1; i < line.offsets.length; i++) {
        var offset = line.offsets[i];
        path.lineTo(offset.dx, offset.dy);
        path.quadraticBezierTo(offset.dx, offset.dy, line.offsets[i - 1].dx,
            line.offsets[i - 1].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
