import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// Generates a gradient that translates (in the direction of alignment) on t.
///
/// Assumes that desired gradient colors are evenly spaced.
///
/// I tried using [GradientTransform] with a translation matrix but it didn't appear to update upon rebuild.
/// This class sends a new gradient with every call of [getGradient].
///
/// For some reason, gradient doesn't appear to change unless [MovingGradient] is inside widget's build method.
class MovingGradient {

  MovingGradient(
      {required this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.tileMode = TileMode.clamp
  });

  final List<Color> colors;

  final Alignment begin;
  final Alignment end;
  final TileMode tileMode;

  late List<Color> _colors = [this.colors, this.colors].expand((e) => e).toList();
  late List<double> _stops = List.generate(N, (index) => 0.0);

  int get n => this.colors.length;
  int get N => this._colors.length;

  //static const double CONTINUITY_TOLERANCE = 0.05;
  //double? _t;

  LinearGradient getGradient(double t) {

    double lower = lerpDouble(n, 0, t)!;
    double upper = lerpDouble(N, n, t)!;
    double interval = upper - lower - 1;

    int n1 = lower.ceil();
    int n2 = upper.ceil();

    // TODO Consider allowing stops to be uneven (would simply need to save stops once and interpolate based on that)
    for(int i = 0; i < N; i++){
        if(i < n1) _stops[i] =  0.0;
        if(i > n2) _stops[i] =  1.0;
        else _stops[i] = (i - lower) / interval;
    }

    // Represents how far away from the edges the gradient is
    double tt = t*n - (t*n).floor();

    _colors[(n1-1) % N] =  Color.lerp(_colors[(n1) % N], _colors[(n1-1) % N], tt)!;
    _colors[(n2-1) % N] = Color.lerp(_colors[(n2-1) % N], _colors[(n2-2) % N], tt)!;

    // Potential problem: if t changes discontinuously (jumps), previous edge correction may carry over
    // Solution to problem withheld since it doesn't matter for now: new MovingGradient must be constructed each build anyway.
    // double diff = ((_t??t) - t).abs();
    // if(diff > CONTINUITY_TOLERANCE) {
    //   for(int i = n1; i <= n2-2; i++) _colors[i] = colors[i % n];
    // }
    //_t = t;

    return LinearGradient(
        begin: begin, end: end,
        colors: _colors,
        stops: _stops
    );
  }

}