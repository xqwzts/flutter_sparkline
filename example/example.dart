import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

math.Random random = new math.Random();

List<double> _generateRandomData(int count) {
  List<double> result = <double>[];
  for (int i = 0; i < count; i++) {
    result.add(random.nextDouble() * 100);
  }
  return result;
}

void main() {
  var data = _generateRandomData(100);
  runApp(
    new MaterialApp(
      home: new Scaffold(
        body: new Center(
          child: new Container(
            width: 300.0,
            height: 100.0,
            child: new Sparkline(
              data: data,
              lineColor: Colors.lightGreen[500],
              fillMode: FillMode.below,
              fillColor: Colors.lightGreen[200],
              pointsMode: PointsMode.all,
              pointSize: 5.0,
              pointColor: Colors.amber,
            ),
          ),
        ),
      ),
    ),
  );
}
