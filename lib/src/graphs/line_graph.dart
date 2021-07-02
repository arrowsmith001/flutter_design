import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class GraphPainter extends CustomPainter{
  GraphPainter({required this.fn, this.begin = 0.0, this.end = 1.0}){

    assert(fn.call(begin) is num);

    double incr = (e - b) / 1000;
    path = new Path()..moveTo(b, fn.call(begin).toDouble());
    for(double d = b; d < e; d += incr){
      double x = d;
      double y = fn.call(d).toDouble();
      //print('x ${x.toString()} y ${y.toString()}');
      path.lineTo(x, y);
    }
  }

  double get b => begin.toDouble();
  double get e => end.toDouble();
  Rect get rect => path.getBounds();

  late Path path;
  late Path pathFit;
  final Function fn;
  final num begin;
  final num end;

  @override
  void paint(Canvas canvas, Size size) {
    print(rect.toString());
    Size scale = new Size(size.width/rect.width, size.height/rect.height);
    double dy = size.height/2;//-rect.top*size.height;
    double y1 = rect.top;
    double y2 = rect.bottom;
    var mat = Matrix4.identity()
      ..translate(0.0, size.height) // TODO adjust dy based on function range (bottom - top)
      ..scale(scale.width, -scale.height)
    ;
    pathFit = path.transform(mat.storage);

    canvas.drawPath(pathFit, Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    _drawAxes(canvas, size);
  }

  TextPainter tp = new TextPainter(textDirection: TextDirection.ltr);
  void _drawAxes(Canvas canvas, Size size){
    double y1 = rect.top;
    double y2 = rect.bottom;
    double incr = (e - b) / 10;
    canvas.translate(0, size.height);
    for(double d = b; d <= e; d += incr){

      String s = d.toStringAsFixed(0);
      tp.text = TextSpan(text: s, style: TextStyle(fontSize: 10, color: Colors.black));
      tp.layout();
      tp.paint(canvas, Offset(0,0));
      canvas.translate((1/10)*size.width, 0);
    }

    canvas.translate(-size.width*(1/10), -tp.height);

    incr = (y2 - y1) / 10;
    for(double d = y1; d < y2 + incr; d += incr){

      String s = d.toStringAsFixed(0);
      print(s.toString());
      tp.text = TextSpan(text: s, style: TextStyle(fontSize: 10, color: Colors.black));
      tp.layout();
      tp.paint(canvas, Offset(0,0));
      canvas.translate(0, -(1/10)*size.height);
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

