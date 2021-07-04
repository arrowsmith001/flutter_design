# design

My library of classes related to Flutter app design. 

Includes clippers, curves, gradients, graphs and text classes/widgets, at varying stages of development.

This library depends on my [extensions library](https://github.com/arrowsmith001/flutter_extensions) to be in the same directory.

## Noteworthy classes

- [<b>MovingGradient</b>](https://github.com/arrowsmith001/flutter_design/blob/master/lib/src/gradients/moving.dart): A class which takes a list of colors, and has method getGradient which returns a linear gradient. The special feature is that getGradient takes argument t (0.0 to 1.0) which linearly translates the colors in the alignment direction. When animated, causes the gradient to "move".

- [<b>PieClipper</b>](https://github.com/arrowsmith001/flutter_design/blob/master/lib/src/clippers/pie.dart): CustomClipper implementation that provides a radial wipe, similar to a countdown timer. Useful for page transitions and timers. I'm hoping to add more features - as of 4.7.21, it only starts at the top and rotates clockwise. Takes argument t (0.0 to 1.0).

- [<b>Curves</b>](https://github.com/arrowsmith001/flutter_design/blob/master/lib/src/curves/curves.dart): The curves library contains a bunch of curves inspired by "Interpolator" implementations from native Android, and a few of my own. There may be similarities with Flutter Curves, but the addition of parameters make mine more flexible.

- [<b>EntryAnimatedText</b>](https://github.com/arrowsmith001/flutter_design/blob/master/lib/src/text/entry_animated.dart): (work in progress) I'm trying to make a solid Text widget which animates it's individual letters in sequence as the widget is first built. I may incorporate ongoing animations to the letters as well.
