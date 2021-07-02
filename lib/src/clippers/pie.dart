import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

/// Creates a "pie" shape whose angle changes based on t (0.0 to 1.0 is a full rotation)
///
/// TODO Add support for choosing initial pointing direction and rotation direction
class PieClipper extends CustomClipper<Path> {

  const PieClipper([this.t = 0.0]);
  final double t;

  @override
  getClip(Size size) {
    double h = size.height;
    double w = size.width;
    double r = 0.5*math.sqrt(math.pow(h, 2) + math.pow(w, 2));

    double h2 = h/2;
    double w2 = w/2;
    Offset center = new Offset(w2, h2);
    double angle = math.pi -t*math.pi*2;

    double x = center.dx + math.sin(angle)*r;
    double y = center.dy + math.cos(angle)*r;

    double xT = x.clamp(0, w);
    double yT = y.clamp(0, h);

    Path path = Path()..moveTo(center.dx, center.dy);
    path.lineTo(xT, yT);

    if(t < 0.25) path.lineTo(w, 0);
    if(t < 0.5) path.lineTo(w, h);
    if(t < 0.75) path.lineTo(0, h);

    path.lineTo(0, 0);
    path.lineTo(w2, 0);
    path.lineTo(center.dx, center.dy);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return (oldClipper as PieClipper).t != t;
  }

}