
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class EntryAnimatedText extends StatefulWidget {

  EntryAnimatedText(this.text, {this.style, this.textAlign,
    this.scaleDuration, this.scaleStagger = 0, this.scaleAnimation});
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration? scaleDuration;
  final Animation<double>? scaleAnimation;
  final double scaleStagger;

  @override
  _EntryAnimatedTextState createState() => _EntryAnimatedTextState();
}

class _EntryAnimatedTextState extends State<EntryAnimatedText> with TickerProviderStateMixin {

  String get text => widget.text;
  TextStyle? get style => widget.style;
  TextAlign? get textAlign => widget.textAlign;
  Duration? get scaleDuration => widget.scaleDuration;
  // Animatable<double>? get scaleTween => widget.scaleTween;
  Animation<double>? get scaleAnimation => widget.scaleAnimation;
  double get scaleStagger => widget.scaleStagger;

  //late AnimationController scaleAnimController;

  late TextPainter tp = new TextPainter(textDirection: TextDirection.ltr);

  @override
  void initState() {
    super.initState();
    if(scaleDuration != null)
    {
      // scaleAnimController = new AnimationController(vsync: this, duration: scaleDuration);
      //
      // scaleAnimController.addListener(() {setState(() {});});
      // scaleAnimController.forward(from: 0);
    }


    _precalculateValues();
  }


  Map<String, double> textDistances = {}; // Map of characters and their laid out horizontal distance
  List<double> cumulativeTextDistances = []; // List of cumulative distance of entire text assuming text is laid out horizontally
  List<int> spaceIndices = []; // Indices where spaces occur in the text TODO Extend to any line-break worthy character
  double? lineHeight;

  void _precalculateValues() {
    cumulativeTextDistances = List.generate(text.length, (index) => 0.0);
    for(int i = 0; i < text.length; i++){
      String char = text[i];
      if(char == ' ') spaceIndices.add(i);
      double d = 0.0;
      if(textDistances.containsKey(char)) d = textDistances[char]!;
      else {
        tp.text = TextSpan(text: char, style: style);
        tp.layout();
        d = tp.maxIntrinsicWidth;
        textDistances.addAll({char : d});
        if(lineHeight == null) lineHeight = tp.height;
      }
      if(i == 0) cumulativeTextDistances[i] = d;
      else cumulativeTextDistances[i] = cumulativeTextDistances[i-1] + d;
    }

    print('textDistances: ' + textDistances.toString());
    print('cumulativeTextDistances: ' + cumulativeTextDistances.toString());
    print('spaceIndices: ' + spaceIndices.toString());
  }

  @override
  void dispose() {
    //scaleAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return CustomPaint(
        size: size,
        painter: EntryAnimatedTextPainter(
            text,
            textDistances, cumulativeTextDistances, spaceIndices, lineHeight ?? 0.0,
            scaleAnimation: scaleAnimation, scaleStagger: scaleStagger, //scaleTween: scaleTween,
            style: style));
  }
}

class EntryAnimatedTextPainter extends CustomPainter {

  EntryAnimatedTextPainter(this.text,
      this.textDistances, this.cumulativeTextDistances, this.spaceIndices, this.lineHeight,
      {this.style, this.scaleAnimation, this.scaleStagger = 0, this.scaleTween})
  {
    if(scaleAnimation != null) _initAnimations();
  }

  late TextPainter tp = new TextPainter(textDirection: TextDirection.ltr);
  final String text;
  final TextStyle? style;

  final Animation<double>? scaleAnimation;
  final Animatable<double>? scaleTween;
  final double scaleStagger;


  List<Animation> anims = [];

  void _initAnimations() {
    assert(scaleAnimation != null);

    int n = text.length;
    double frac = 1/n;
    double dur = lerpDouble(frac, 1.0, (1 - scaleStagger))!;
    double incr = (1-dur)/n;

    double begin = 0.0;
    double end = dur;

    for(int i = 0; i < text.length; i++){
      //var curve = Interval(begin, end, curve: scaleTween);
      var entryAnim = CurveTween(curve: Interval(begin, end)).animate(scaleAnimation!);
      anims.add(entryAnim);

      begin += incr;
      end += incr;
    }
  }

  final Map<String, double> textDistances; // Map of characters and their laid out horizontal distance
  final List<double> cumulativeTextDistances; // List of cumulative distance of entire text assuming text is laid out horizontally
  final List<int> spaceIndices; // Indices where spaces occur in the text TODO Extend to any line-break worthy character
  final double lineHeight;

  int get n => text.length;

  // TODO Fix text overflow issue
  @override
  void paint(Canvas canvas, Size size) {

    double w = size.width;
    double h = size.height;

    int start = 0;
    double lineDistance = 0.0;
    double distanceBeforeLastSpace = 0.0;
    int indexBeforeLastSpace = 0;
    int indexAfterLastSpace = 0;
    double lastLinesDistance = 0.0;

    int i = 0;
    while(i < n){
      while(i < n && text[i] != ' ') i++;

      indexBeforeLastSpace = i-1;
      distanceBeforeLastSpace = cumulativeTextDistances[indexBeforeLastSpace] - lastLinesDistance;

      while(i < n && text[i] == ' ') i++; // Advances i to start of next word
      indexAfterLastSpace = i;

      lineDistance = cumulativeTextDistances[indexBeforeLastSpace] - lastLinesDistance;
      if(lineDistance >= w || i == n){
        //print(i.toString() + ' ' + lineDistance.toString());

        int j = indexBeforeLastSpace;
        double d = distanceBeforeLastSpace;

        double marginDistance = w - d;
        marginDistance /= 2;

        canvas.translate(marginDistance, 0);
        double x = 0.0;
        for(int k = start; k <= j; k++){
          double d = _drawLetter(canvas, size, k);
          canvas.translate(d, 0);
          x += d;
        }
        canvas.translate(-x - marginDistance, lineHeight);

        lastLinesDistance = cumulativeTextDistances[indexAfterLastSpace-1];
        start = indexAfterLastSpace;
        i = indexAfterLastSpace;
      };

    }

    //print('end');
    // dx = 0.0;
    // dy = 0.0;
    // x = 0.0;
    // lastBreak = 0;
    // nextBreak = spaceIndices[0];
    // spaceIndex = 0;
    // wrapAtNextSpace = false;
    // notWrappedYet = true;
    // lastWrap = 0;
    //
    // tp.text = TextSpan(text: ' ', style: style);
    // tp.layout(minWidth: 0, maxWidth: double.maxFinite);
    // double spaceLength = tp.maxIntrinsicWidth;
    //
    // for(int i = 0; i < text.length; i++){
    //
    //   if(text[i] == ' ') {
    //     if(wrapAtNextSpace){
    //       canvas.translate(-x - (notWrappedYet ? spaceLength : 0), tp.height);
    //       x = 0.0;
    //       wrapAtNextSpace = false;
    //       if(notWrappedYet) notWrappedYet = false;
    //       //lastWrap =
    //     }
    //
    //     spaceIndex++;
    //     lastBreak = nextBreak + 1;
    //     nextBreak = spaceIndices[spaceIndex];
    //   }
    //
    //   // TODO Cache measurements for next round
    //   // Measure current 'word'
    //   String word = text.substring(lastBreak, nextBreak);
    //   tp.text = TextSpan(text: word, style: style);
    //   tp.layout(minWidth: 0, maxWidth: double.maxFinite);
    //
    //   double w = tp.maxIntrinsicWidth;
    //
    //   if(x + w + spaceLength >= size.width) {
    //     wrapAtNextSpace = true;
    //   }
    //
    //   _drawLetter(canvas, size, i);
    // }
  }

  /// Returns the maxInstrinsicWidth of the given laid-out letter
  double _drawLetter(Canvas canvas, Size size, int i) {

    double v;

    try{
      v = anims[i].value;
    }catch(e)
    {
      v = 1;
    }

    String s = text[i];

    tp.text = TextSpan(text: s, style: style);
    tp.layout();

    double w = tp.maxIntrinsicWidth;
    double h = tp.height;
    Offset c = new Offset(w/2, h/2);

    canvas.translate((1-v)*c.dx, (1-v)*c.dy);
    canvas.scale(v);
    tp.paint(canvas, Offset(0,0));
    canvas.scale(1/v);
    canvas.translate(-(1-v)*c.dx, -(1-v)*c.dy);

    return w;
    // if(x + dx >= size.width){
    //   canvas.translate(-x + dx, tp.height);
    //   x = 0.0;
    // }
    // else{
    // }
  }

  bool get _shouldRepaint => true;//!controller!.isCompleted; // TODO Optimize

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _shouldRepaint;
  }




}

