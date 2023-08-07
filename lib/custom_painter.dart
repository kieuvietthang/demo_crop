import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class MyImagePainter extends CustomPainter {
  final ui.Image image;
  final int height;
  final bool crop;
  final BuildContext context;
  final List<Offset> pointList;

  MyImagePainter(
    this.pointList, {
    required this.image,
    required this.height,
    required this.crop,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, new Offset(0, 0), Paint());
    if (pointList.isNotEmpty && !crop) {
      canvas.drawPoints(
          ui.PointMode.polygon,
          pointList,
          Paint()
            ..strokeWidth = 20 * (image.height / height)
            ..strokeCap = StrokeCap.round
            ..color = Colors.red
            );
      canvas.drawLine(
          pointList[0],
          pointList[pointList.length - 1],
          Paint()
            ..strokeWidth = 3.0
            ..color = Colors.white
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw true;
  }
}
