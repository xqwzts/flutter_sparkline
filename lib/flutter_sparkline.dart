library flutter_sparkline;

import 'dart:math' as math;
import 'dart:ui' as ui show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Strategy used when filling the area of a sparkline.
enum FillMode {
  /// Do not fill, draw only the sparkline.
  none,

  /// Fill the area above the sparkline: creating a closed path from the line
  /// to the upper edge of the widget.
  above,

  /// Fill the area below the sparkline: creating a closed path from the line
  /// to the lower edge of the widget.
  below,
}

/// A widget that draws a sparkline chart.
///
/// The area above or below the sparkline can be filled with the provided
/// [fillColor] by setting the desired [fillMode].
///
/// If neither [pointSize] nor [pointColor] are specified then individual data
/// points will not be drawn over the sparkline. If only one of them is provided
/// then the other property will default to the corresponding line-value:
/// [lineWidth] for the size and [lineColor] for the color.
///
/// By default, the sparkline is sized to fit its container. If the
/// sparkline is in an unbounded space, it will size itself according to the
/// given [fallbackWidth] and [fallbackHeight].
class Sparkline extends StatelessWidget {
  Sparkline({
    Key key,
    @required this.data,
    this.lineWidth = 2.0,
    this.lineColor = Colors.lightBlue,
    this.pointSize,
    this.pointColor,
    this.sharpCorners = false,
    this.fillMode = FillMode.none,
    this.fillColor = const Color(0xFF81D4FA), //Colors.lightBlue[200]
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
  })  : assert(data != null),
        assert(lineWidth != null),
        assert(lineColor != null),
        assert(sharpCorners != null),
        assert(fillMode != null),
        assert(fillColor != null),
        assert(fallbackHeight != null),
        assert(fallbackWidth != null),
        super(key: key);

  final List<double> data;
  final double lineWidth;
  final Color lineColor;

  /// The size to use when drawing individual data points over the sparkline.
  ///
  /// At least one of [pointSize] or [pointColor] must be set, or data points
  /// will not be drawn.
  ///
  /// If [pointSize] is set, but [pointColor] is not, then [lineColor] will be
  /// used as the color.
  final double pointSize;

  /// The color used when drawing individual data points over the sparkline.
  ///
  /// At least one of [pointSize] or [pointColor] must be set, or data points
  /// will not be drawn.
  ///
  /// If [pointColor] is set, but [pointSize] is not, then [lineWidth] will be
  /// used as the size.
  final Color pointColor;

  final bool sharpCorners;

  /// Determines the area that should be filled with [fillColor].
  ///
  /// Defaults to [FillMode.none].
  final FillMode fillMode;

  /// The fill color used in the chart, as determined by [fillMode].
  ///
  /// Defaults to Colors.lightBlue[200].
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
          fillMode: fillMode,
          fillColor: fillColor,
          pointSize: pointSize,
          pointColor: pointColor,
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
    @required this.fillMode,
    @required this.fillColor,
    this.pointSize,
    this.pointColor,
  })  : _max = dataPoints.reduce(math.max),
        _min = dataPoints.reduce(math.min),
        _drawPoints = pointSize != null || pointColor != null;

  final List<double> dataPoints;
  final double lineWidth;
  final Color lineColor;
  final bool sharpCorners;
  final FillMode fillMode;
  final Color fillColor;
  final double pointSize;
  final Color pointColor;
  final bool _drawPoints;

  final double _max;
  final double _min;

  @override
  void paint(Canvas canvas, Size size) {
    final double widthNormalizer = size.width / (dataPoints.length - 1);
    final double heightNormalizer = size.height / (_max - _min);

    final Path path = new Path();
    final List<Offset> points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthNormalizer;
      double y = size.height - (dataPoints[i] - _min) * heightNormalizer;

      if (_drawPoints) {
        points.add(new Offset(x, y));
      }

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

    if (fillMode != FillMode.none) {
      Path fillPath = new Path()..addPath(path, Offset.zero);
      if (fillMode == FillMode.below) {
        fillPath.lineTo(size.width, size.height);
        fillPath.lineTo(0.0, size.height);
      } else if (fillMode == FillMode.above) {
        fillPath.lineTo(size.width, 0.0);
        fillPath.lineTo(0.0, 0.0);
      }
      fillPath.close();
      Paint fillPaint = new Paint()
        ..strokeWidth = 0.0
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);

    if (_drawPoints) {
      Paint pointsPaint = new Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pointSize ?? lineWidth
        ..color = pointColor ?? lineColor;
      canvas.drawPoints(ui.PointMode.points, points, pointsPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return dataPoints != old.dataPoints;
  }
}
