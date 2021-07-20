import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class RoundedTriangleClipper extends CustomClipper<Path>{
  RoundedTriangleClipper({this.angle = 0.0, this.bulge = 0.3});

  /// The angle at which the triangle is offset. Takes values between 0.0 and
  /// 1.0, 0.0 being no offset and 1.0 being a full rotation.
  final double angle;

  /// "Bulge" factor.
  ///
  /// 0.0 gives the default Bezier curves where the 3 triangle
  /// points and 3 control points all lie on the same circle.
  ///
  /// As this value increases, the 3 triangle points move closer towards the
  /// center, and the control points move away from the center at the same rate.
  /// The result is that the maximum points inscribed by the control points
  /// appear to be stationary.
  ///
  /// At 0.3 (default value), the corners appear to be at their smoothest. If
  /// this is the aesthetic you're going for, a value around 0.3 is
  /// recommended.
  ///
  /// At 1.0, the 3 triangle points collapse into the centre.
  final double bulge;

  @override
  Path getClip(Size size) {
    const double twopi = math.pi*2;

    final path = new Path();
    final double r = math.min(size.width, size.height) / 2;
    final Offset c = new Offset(size.width/2, size.height/2);

    final double rBulged = r * (1 + bulge);
    final double rCaved = r * (1 - bulge);

    final double angleOffset = twopi*angle;

    final double pAngle1 = 0 + angleOffset;
    final double pAngle2 = twopi/3 + angleOffset;
    final double pAngle3 = 2*twopi/3 + angleOffset;
    final double cAngle12 = lerpDouble(pAngle1, pAngle2, 0.5)!;
    final double cAngle23 = lerpDouble(pAngle2, pAngle3, 0.5)!;
    final double cAngle31 = lerpDouble(pAngle3, pAngle1 + twopi, 0.5)!;

    Offset p1 = new Offset(c.dx + rCaved*math.cos(pAngle1), c.dy + rCaved*math.sin(pAngle1));
    Offset p2 = new Offset(c.dx + rCaved*math.cos(pAngle2), c.dy + rCaved*math.sin(pAngle2));
    Offset p3 = new Offset(c.dx + rCaved*math.cos(pAngle3), c.dy + rCaved*math.sin(pAngle3));

    Offset c12 = new Offset(c.dx + rBulged*math.cos(cAngle12), c.dy + rBulged*math.sin(cAngle12));
    Offset c23 = new Offset(c.dx + rBulged*math.cos(cAngle23), c.dy + rBulged*math.sin(cAngle23));
    Offset c31 = new Offset(c.dx + rBulged*math.cos(cAngle31), c.dy + rBulged*math.sin(cAngle31));

    path.moveTo(p1.dx, p1.dy);
    path.quadraticBezierTo(c12.dx, c12.dy, p2.dx, p2.dy);
    path.quadraticBezierTo(c23.dx, c23.dy, p3.dx, p3.dy);
    path.quadraticBezierTo(c31.dx, c31.dy, p1.dx, p1.dy);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return (oldClipper as RoundedTriangleClipper).bulge != this.bulge
      || (oldClipper as RoundedTriangleClipper).angle != this.angle;
  }

}