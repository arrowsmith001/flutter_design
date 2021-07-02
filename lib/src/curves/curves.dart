import 'dart:math';
import 'package:flutter/animation.dart';

/// For animations that go slightly beyond the final threshold, then back
class OvershootCurve extends Curve {
  OvershootCurve([this.T = 1]);
  final double T;

  @override
  double transform(double t) {
    return (T+1) * pow(t-1,3) + T * pow(t-1,2) + 1;
  }
}


/// For animations that go slightly behind the initial value, then forward
class AnticipateCurve extends Curve{
  AnticipateCurve([this.T = 1]);
  final double T;

  @override
  double transform(double t) {
    return (T+1) * pow(t,3) - T * pow(t,2);
  }
}

/// For animations that go slightly behind the initial value and slightly beyond the final threshold
class AnticipateOvershootCurve extends Curve{
  const AnticipateOvershootCurve([this.T = 1]);
  final double T;

  @override
  double transform(double t) {
    if(t<0.5) return 0.5*((T+1)*pow(2*t,3)-T*(pow(2*t,2)));
    return 0.5*((T+1)*pow(2*t-2,3)+T*(pow(2*t-2,2))) + 1;
  }
}

/// For animations that have a "bounce" effect
class BounceCurve extends Curve{
  const BounceCurve();

  @override
  double transform(double t) {
    if(t<0.31489) return 8*pow(1.1226*t,2).toDouble();
    if(t<0.65990) return 8*pow(1.1226*t - 0.54719, 2) + 0.7;
    if(t<0.85908) return 8*pow(1.1226*t - 0.8526, 2) + 0.9;
    return 8*pow(1.1226*t - 1.0435, 2) + 0.95;
  }
}

/// For animations than slow down towards the end
class DecelerateCurve extends Curve{
  const DecelerateCurve([this.T=1]);
  final double T;

  @override
  double transform(double t) {
    return (1 - pow(1-t, 2*T)).toDouble();
  }
}

/// For animations that jump and then return as a bounce
class JumpThenBounceCurve extends Curve{

  const JumpThenBounceCurve();
  final Curve decel = const DecelerateCurve();
  final Curve bounce = const BounceCurve();

  @override
  double transform(double t) {
    if(t < 0.5) return decel.transform(2*t);
    return 1-bounce.transform(2*(t-0.5));
  }
}

/// Trig curve
abstract class TrigCurve extends Curve {

  const TrigCurve([this.factor = 1.0, this.offset = 0.0, this.amp = 1.0, this.abs = false]);

  /// How horizontally stretched the curve is (>0, <1.0 = compressed, 1.0 = normal (default), >1.0 = stretched)
  final double factor;

  /// How offset the curve is from the trig function as a multiple of 2*pi (0.0 = no offset (default), 0.5 = offset by pi, etc.)
  final double offset;

  /// A multiplier that decides the amplitude of the wave (default: 1.0)
  final double amp;

  /// True: the absolute value of the result is output.
  /// False: (default) the absolute value is not output.
  final bool abs;
}

class SinCurve extends TrigCurve{
  SinCurve({factor = 1.0, offset = 0.0, amp = 1.0, abs = false}) : super(factor, offset, amp, abs);

  @override
  double transform(double t) {
    double d = amp*sin(2*pi*(t*factor + offset));
    if(!abs) return d;
    return max(0.0, d);
  }
}

class CosCurve extends TrigCurve{
  CosCurve({factor = 1.0, offset = 0.0, amp = 1.0, abs = false}) : super(factor, offset, amp, abs);

  @override
  double transform(double t) {
    double d = amp*cos(2*pi*(t*factor + offset));
    if(!abs) return d;
    return max(0.0, d);
  }
}