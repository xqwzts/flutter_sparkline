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

/// Strategy used when drawing individual data points over the sparkline.
enum PointsMode {
  /// Do not draw individual points.
  none,

  /// Draw all the points in the data set.
  all,

  /// Draw only the last point in the data set.
  last,
}

/// A widget that draws a sparkline chart.
///
/// Represents the given [data] in a sparkline chart that spans the available
/// space.
///
/// By default only the sparkline is drawn, with its looks defined by
/// the [lineWidth], [lineColor], and [lineGradient] properties.
///
/// The y-scale of the sparkline will be determined by using the [data]'s
/// minimum and maximum value, unless overridden with [min] and/or [max].
///
/// The corners between two segments of the sparkline can be made sharper by
/// setting [sharpCorners] to true.
///
/// Conversely, to smooth out the curve drawn even more, set [useCubicSmoothing]
/// to true. The degree to which the cubic smoothing is applied can be changed
/// using [cubicSmoothingFactor]. A good range for [cubicSmoothingFactor]
/// is usually between 0.1 and 0.3.
///
/// The area above or below the sparkline can be filled with the provided
/// [fillColor] or [fillGradient] by setting the desired [fillMode].
///
/// [pointsMode] controls how individual points are drawn over the sparkline
/// at the provided data point. Their appearance is determined by the
/// [pointSize] and [pointColor] properties.
///
/// By default, the sparkline is sized to fit its container. If the
/// sparkline is in an unbounded space, it will size itself according to the
/// given [fallbackWidth] and [fallbackHeight].
class Sparkline extends StatelessWidget {
  /// Creates a widget that represents provided [data] in a Sparkline chart.
  Sparkline({
    Key key,
    @required this.data,
    this.lineWidth = 2.0,
    this.lineColor = Colors.lightBlue,
    this.lineGradient,
    this.pointsMode = PointsMode.none,
    this.pointSize = 4.0,
    this.pointColor = const Color(0xFF0277BD), //Colors.lightBlue[800]
    this.sharpCorners = false,
    this.useCubicSmoothing = false,
    this.cubicSmoothingFactor = 0.15,
    this.fillMode = FillMode.none,
    this.fillColor = const Color(0xFF81D4FA), //Colors.lightBlue[200]
    this.fillGradient,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.enableGridLines = false,
    this.gridLineColor = Colors.grey,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
    this.gridLineLabelColor = Colors.grey,
    this.labelPrefix = "\$",
    this.max,
    this.min,
  })  : assert(data != null),
        assert(lineWidth != null),
        assert(lineColor != null),
        assert(pointsMode != null),
        assert(pointSize != null),
        assert(pointColor != null),
        assert(sharpCorners != null),
        assert(fillMode != null),
        assert(fillColor != null),
        assert(fallbackHeight != null),
        assert(fallbackWidth != null),
        super(key: key);

  /// List of values to be represented by the sparkline.
  ///
  /// Each data entry represents an individual point on the chart, with a path
  /// drawn connecting the consecutive points to form the sparkline.
  ///
  /// The values are normalized to fit within the bounds of the chart.
  final List<double> data;

  /// The width of the sparkline.
  ///
  /// Defaults to 2.0.
  final double lineWidth;

  /// The color of the sparkline.
  ///
  /// Defaults to Colors.lightBlue.
  ///
  /// This is ignored if [lineGradient] is non-null.
  final Color lineColor;

  /// A gradient to use when coloring the sparkline.
  ///
  /// If this is specified, [lineColor] has no effect.
  final Gradient lineGradient;

  /// Determines how individual data points should be drawn over the sparkline.
  ///
  /// Defaults to [PointsMode.none].
  final PointsMode pointsMode;

  /// The size to use when drawing individual data points over the sparkline.
  ///
  /// Defaults to 4.0.
  final double pointSize;

  /// The color used when drawing individual data points over the sparkline.
  ///
  /// Defaults to Colors.lightBlue[800].
  final Color pointColor;

  /// Determines if the sparkline path should have sharp corners where two
  /// segments intersect.
  ///
  /// Defaults to false.
  final bool sharpCorners;

  /// Determines if the sparkline path should use cubic beziers to smooth
  /// the curve when drawing. Read more about the algorithm used, here:
  ///
  /// https://medium.com/@francoisromain/smooth-a-svg-path-with-cubic-bezier-curves-e37b49d46c74
  ///
  /// Defaults to false.
  final bool useCubicSmoothing;

  /// How aggressively the sparkline should apply cubic beziers to smooth
  /// the curves. A good value is usually between 0.1 and 0.3.
  ///
  /// Defaults to 0.15.
  final double cubicSmoothingFactor;

  /// Determines the area that should be filled with [fillColor].
  ///
  /// Defaults to [FillMode.none].
  final FillMode fillMode;

  /// The fill color used in the chart, as determined by [fillMode].
  ///
  /// Defaults to Colors.lightBlue[200].
  ///
  /// This is ignored if [fillGradient] is non-null.
  final Color fillColor;

  /// A gradient to use when filling the chart, as determined by [fillMode].
  ///
  /// If this is specified, [fillColor] has no effect.
  final Gradient fillGradient;

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

  /// Enable or disable grid lines
  final bool enableGridLines;

  /// Color of grid lines and label text
  final Color gridLineColor;
  final Color gridLineLabelColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// Symbol prefix for grid line labels
  final String labelPrefix;

  /// The maximum value for the rendering box. Will default to the largest
  /// value in [data].
  final double max;

  /// The minimum value for the rendering box. Will default to the largest
  /// value in [data].
  final double min;

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
          lineGradient: lineGradient,
          sharpCorners: sharpCorners,
          useCubicSmoothing: useCubicSmoothing,
          cubicSmoothingFactor: cubicSmoothingFactor,
          fillMode: fillMode,
          fillColor: fillColor,
          fillGradient: fillGradient,
          pointsMode: pointsMode,
          pointSize: pointSize,
          pointColor: pointColor,
          enableGridLines: enableGridLines,
          gridLineColor: gridLineColor,
          gridLineAmount: gridLineAmount,
          gridLineLabelColor: gridLineLabelColor,
          gridLineWidth: gridLineWidth,
          labelPrefix: labelPrefix,
          max: max,
          min: min,
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
    this.lineGradient,
    @required this.sharpCorners,
    @required this.useCubicSmoothing,
    @required this.cubicSmoothingFactor,
    @required this.fillMode,
    @required this.fillColor,
    this.fillGradient,
    @required this.pointsMode,
    @required this.pointSize,
    @required this.pointColor,
    @required this.enableGridLines,
    @required this.gridLineColor,
    @required this.gridLineAmount,
    @required this.gridLineWidth,
    @required this.gridLineLabelColor,
    @required this.labelPrefix,
    double max,
    double min,
  })  : _max = max != null ? max : dataPoints.reduce(math.max),
        _min = min != null ? min : dataPoints.reduce(math.min);

  final List<double> dataPoints;

  final double lineWidth;
  final Color lineColor;
  final Gradient lineGradient;

  final bool sharpCorners;
  final bool useCubicSmoothing;
  final double cubicSmoothingFactor;

  final FillMode fillMode;
  final Color fillColor;
  final Gradient fillGradient;

  final PointsMode pointsMode;
  final double pointSize;
  final Color pointColor;

  final double _max;
  final double _min;

  final bool enableGridLines;
  final Color gridLineColor;
  final int gridLineAmount;
  final double gridLineWidth;
  final Color gridLineLabelColor;
  final String labelPrefix;

  List<TextPainter> gridLineTextPainters = [];

  update() {
    if (enableGridLines) {
      double gridLineValue;
      for (int i = 0; i < gridLineAmount; i++) {
        // Label grid lines
        gridLineValue = _max - (((_max - _min) / (gridLineAmount - 1)) * i);

        String gridLineText;
        if (gridLineValue < 1) {
          gridLineText = gridLineValue.toStringAsPrecision(4);
        } else if (gridLineValue < 999) {
          gridLineText = gridLineValue.toStringAsFixed(2);
        } else {
          gridLineText = gridLineValue.round().toString();
        }

        gridLineTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: labelPrefix + gridLineText,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineTextPainters[i].layout();
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width - lineWidth;
    final double height = size.height - lineWidth;
    final double heightNormalizer = height / (_max - _min);

    final List<Offset> points = <Offset>[];
    final List<Offset> normalized = <Offset>[];

    if (gridLineTextPainters.isEmpty) {
      update();
    }

    if (enableGridLines) {
      width = size.width - gridLineTextPainters[0].text.text.length * 6;
      Paint gridPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = gridLineWidth;

      double gridLineDist = height / (gridLineAmount - 1);
      double gridLineY;

      // Draw grid lines
      for (int i = 0; i < gridLineAmount; i++) {
        gridLineY = (gridLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(0.0, gridLineY),
            new Offset(width, gridLineY), gridPaint);

        // Label grid lines
        gridLineTextPainters[i]
            .paint(canvas, new Offset(width + 2.0, gridLineY - 6.0));
      }
    }

    final double widthNormalizer = width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthNormalizer + lineWidth / 2;
      double y =
          height - (dataPoints[i] - _min) * heightNormalizer + lineWidth / 2;

      normalized.add(new Offset(x, y));

      if (pointsMode == PointsMode.all ||
          (pointsMode == PointsMode.last && i == dataPoints.length - 1)) {
        points.add(normalized[i]);
      }
    }

    Offset startPoint = normalized[0];
    final Path path = new Path();
    path.moveTo(startPoint.dx, startPoint.dy);

    if (useCubicSmoothing) {
      Offset a = normalized[0];
      Offset b = normalized[0];
      Offset c = normalized[1];
      for (int i = 1; i < normalized.length; i++) {
        double x1 = (c.dx - a.dx) * cubicSmoothingFactor + b.dx;
        double y1 = (c.dy - a.dy) * cubicSmoothingFactor + b.dy;
        a = b;
        b = c;
        c = normalized[math.min(normalized.length - 1, i + 1)];
        double x2 = (a.dx - c.dx) * cubicSmoothingFactor + b.dx;
        double y2 = (a.dy - c.dy) * cubicSmoothingFactor + b.dy;
        path.cubicTo(x1, y1, x2, y2, b.dx, b.dy);
      }
    } else {
      for (int i = 1; i < normalized.length; i++) {
        path.lineTo(normalized[i].dx, normalized[i].dy);
      }
    }

    Paint paint = new Paint()
      ..strokeWidth = lineWidth
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = sharpCorners ? StrokeJoin.miter : StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (lineGradient != null) {
      final Rect lineRect = new Rect.fromLTWH(0.0, 0.0, width, height);
      paint.shader = lineGradient.createShader(lineRect);
    }

    if (fillMode != FillMode.none) {
      Path fillPath = new Path()..addPath(path, Offset.zero);
      if (fillMode == FillMode.below) {
        fillPath.relativeLineTo(lineWidth / 2, 0.0);
        fillPath.lineTo(size.width, size.height);
        fillPath.lineTo(0.0, size.height);
        fillPath.lineTo(startPoint.dx - lineWidth / 2, startPoint.dy);
      } else if (fillMode == FillMode.above) {
        fillPath.relativeLineTo(lineWidth / 2, 0.0);
        fillPath.lineTo(size.width, 0.0);
        fillPath.lineTo(0.0, 0.0);
        fillPath.lineTo(startPoint.dx - lineWidth / 2, startPoint.dy);
      }
      fillPath.close();

      Paint fillPaint = new Paint()
        ..strokeWidth = 0.0
        ..color = fillColor
        ..style = PaintingStyle.fill;

      if (fillGradient != null) {
        final Rect fillRect = new Rect.fromLTWH(0.0, 0.0, width, height);
        fillPaint.shader = fillGradient.createShader(fillRect);
      }
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);

    if (points.isNotEmpty) {
      Paint pointsPaint = new Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pointSize
        ..color = pointColor;
      canvas.drawPoints(ui.PointMode.points, points, pointsPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return dataPoints != old.dataPoints ||
        lineWidth != old.lineWidth ||
        lineColor != old.lineColor ||
        lineGradient != old.lineGradient ||
        sharpCorners != old.sharpCorners ||
        fillMode != old.fillMode ||
        fillColor != old.fillColor ||
        fillGradient != old.fillGradient ||
        pointsMode != old.pointsMode ||
        pointSize != old.pointSize ||
        pointColor != old.pointColor ||
        enableGridLines != old.enableGridLines ||
        gridLineColor != old.gridLineColor ||
        gridLineAmount != old.gridLineAmount ||
        gridLineWidth != old.gridLineWidth ||
        gridLineLabelColor != old.gridLineLabelColor ||
        useCubicSmoothing != old.useCubicSmoothing;
  }
}
