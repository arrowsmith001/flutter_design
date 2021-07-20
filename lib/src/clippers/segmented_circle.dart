import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

/// Cuts out a circle (or ring) segmented, like "pineapple chunks".
class SegmentedCircle extends CustomClipper<Path> {
  SegmentedCircle({this.inner = 0.1, this.outer = 1.0, this.gap = 0.1, required this.segments})
  {
    assert(inner < outer);
    assert(segments > 0);
  }

  /// Radius proportion of the inner negative-space circle. Must be less than [outer] and between 0.0 and 1.0.
  /// 0.1 is default.
  final double inner;

  /// Radius proportion of the outer circle. Must be greater than [inner] and between 0.0 and 1.0.
  /// 1.0 is default and denotes the largest circle that can be contained within bounds.
  final double outer;

  /// Proportion of the [inner] radius value that is allotted as empty space between segments.
  /// The [outer] space is calculated accordingly.
  /// 0.1 is default. Result is sensible for values between 0.0 and 1.0 (go outside this range if you dare).
  final double gap;

  /// Number of segments. Must be greater than 0.
  final int segments;

  @override
  Path getClip(Size size) {
    const double twopi = math.pi*2;

    final path = new Path();
    final double r = math.min(size.width, size.height) / 2;
    final Offset c = new Offset(size.width/2, size.height/2);

    final innerRadius = r * this.inner;
    final outerRadius = r * this.outer;

    if(this.segments == 1)
    {
      path.fillType = PathFillType.evenOdd;
      path.addOval(new Rect.fromCircle(center: c, radius: outerRadius));
      path.addOval(new Rect.fromCircle(center: c, radius: innerRadius));
      return path;
    }

    final angleIncr = twopi / segments; // Total angle increment for each segment and gap.

    final innerSegmentIncr = angleIncr * (1-this.gap); // Angle increment for the inner segment without the gap
    final gapIncr = angleIncr * (this.gap); // Angle increment for the inner gap only
    final gapLength = gapIncr * innerRadius; // Actual length of the inner gap
    final outerSegmentLength = (twopi * outerRadius / segments) - gapLength; // Actual length of the outer segment (adjusted for gap)
    final outerSegmentIncr = outerSegmentLength / outerRadius; // Angle increment for the outer segment without the gap

    double angle = 0.0;
    for(int i = 0; i < segments; i++)
    {
      final double xi1 = c.dx + innerRadius * math.sin(angle - innerSegmentIncr/2);
      final double yi1 = c.dy + innerRadius * math.cos(angle - innerSegmentIncr/2);

      final double xi2 = c.dx + innerRadius * math.sin(angle + innerSegmentIncr/2);
      final double yi2 = c.dy + innerRadius * math.cos(angle + innerSegmentIncr/2);

      final double xo1 = c.dx + outerRadius * math.sin(angle - outerSegmentIncr/2);
      final double yo1 = c.dy + outerRadius * math.cos(angle - outerSegmentIncr/2);

      final double xo2 = c.dx + outerRadius * math.sin(angle + outerSegmentIncr/2);
      final double yo2 = c.dy + outerRadius * math.cos(angle + outerSegmentIncr/2);

      final segment = new Path();
      segment.moveTo(xi1, yi1);
      segment.lineTo(xo1, yo1);
      segment.arcToPoint(new Offset(xo2, yo2), radius: Radius.circular(outerRadius), clockwise: false);
      segment.lineTo(xi2, yi2);
      segment.arcToPoint(new Offset(xi1, yi1), radius: Radius.circular(innerRadius));

      path.addPath(segment, Offset.zero);

      angle += angleIncr;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
