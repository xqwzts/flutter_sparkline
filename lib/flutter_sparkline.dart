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

class Sparkline extends StatelessWidget {
  final List<double> data = _generateRandomData(5);

  final double lineWidth;
  final Color lineColor;

  Sparkline({this.lineWidth = 15.0, this.lineColor = Colors.green});

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.red,
      width: 200.0,
      height: 100.0,
      child: new CustomPaint(
        painter: new _SparklinePainter(
          data,
          lineWidth: lineWidth,
          lineColor: lineColor,
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
  })  : _max = dataPoints.reduce(math.max),
        _min = dataPoints.reduce(math.min);

  final List<double> dataPoints;
  final double lineWidth;
  final Color lineColor;

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
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return dataPoints != old.dataPoints;
  }
}
