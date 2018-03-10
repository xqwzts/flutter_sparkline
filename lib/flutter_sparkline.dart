library flutter_sparkline;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

math.Random random = new math.Random();

List<double> _generateRandomData(int count) {
  List<double> result = <double>[];
  for (int i = 0; i < count; i++) {
    result.add(random.nextDouble() * 100);
  }
  return result;
}

/// A widget that draws a sparkline chart.
///
/// By default, the sparkline is sized to fit its container. If the
/// sparkline is in an unbounded space, it will size itself according to the
/// given [fallbackWidth] and [fallbackHeight].
class Sparkline extends StatelessWidget {
  Sparkline({
    Key key,
    this.lineWidth = 2.0,
    this.lineColor = Colors.lightBlue,
    this.sharpCorners = false,
    this.fillColor = const Color(0xFF81D4FA), //Colors.lightBlue[200]
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
  }) : super(key: key);

  final double lineWidth;
  final Color lineColor;
  final bool sharpCorners;
  final Color fillColor;

  /// The width to use when the sparkline is in a situation with an unbounded
  /// width.
  ///
  /// See also:
  ///
  ///  * [fallbackHeight], the same but vertically.
  final double fallbackWidth;

  /// The height to use when the sparkline is in a situation with an unbounded
  /// height.
  ///
  /// See also:
  ///
  ///  * [fallbackWidth], the same but horizontally.
  final double fallbackHeight;

  final List<double> data = _generateRandomData(25);

  @override
  Widget build(BuildContext context) {
    return new LimitedBox(
      maxWidth: fallbackWidth,
      maxHeight: fallbackHeight,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _SparklinePainter(
          data,
          lineWidth: lineWidth,
          lineColor: lineColor,
          sharpCorners: sharpCorners,
          fillColor: fillColor,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(
    this.dataPoints, {
    @required this.lineWidth,
    @required this.lineColor,
    @required this.sharpCorners,
    @required this.fillColor,
  })  : _max = dataPoints.reduce(math.max),
        _min = dataPoints.reduce(math.min);

  final List<double> dataPoints;
  final double lineWidth;
  final bool sharpCorners;
  final Color lineColor;
  final Color fillColor;

  final double _max;
  final double _min;

  @override
  void paint(Canvas canvas, Size size) {
    print('max: $_max, min: $_min: size: $size');

    final double widthNormalizer = size.width / (dataPoints.length - 1);
    final double heightNormalizer = size.height / (_max - _min);

    print('wn: $widthNormalizer, hn: $heightNormalizer');

    final Path path = new Path();

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthNormalizer;
      double y = size.height - (dataPoints[i] - _min) * heightNormalizer;
      print('painting: ${dataPoints[i]} ($x, $y)');
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    Paint paint = new Paint()
      ..strokeWidth = lineWidth
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = sharpCorners ? StrokeJoin.miter : StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (fillColor != null) {
      Path fillPath = new Path()..addPath(path, Offset.zero);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0.0, size.height);
      fillPath.close();
      Paint fillPaint = new Paint()
        ..strokeWidth = 0.0
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return dataPoints != old.dataPoints;
  }
}
