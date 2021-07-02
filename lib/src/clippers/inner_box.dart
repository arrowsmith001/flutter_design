import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

/// Clips out a centered box (t: [0.0, 1.0] determines the box size relative to parent)
class InnerBoxClipper extends CustomClipper<Path> {

  const InnerBoxClipper([this.t = 0.0]);
  final double t;

  @override
  getClip(Size size) {
    double h = size.height;
    double w = size.width;

    double h2 = h/2;
    double w2 = w/2;
    Offset center = new Offset(w2, h2);

    Offset topLeft = new Offset((1-t)*center.dx, (1-t)*center.dy);
    Offset bottomRight = new Offset(w - (1-t)*center.dx, h - (1-t)*center.dy);

    Path path = Path()
      ..addRect(new Rect.fromPoints(topLeft, bottomRight))
      ..addRect(new Rect.fromLTWH(0, 0, w, h))
    ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return (oldClipper as InnerBoxClipper).t != t;
  }

}