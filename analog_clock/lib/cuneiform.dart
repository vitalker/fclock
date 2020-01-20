import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// It's based on the one of the oldest way to draw numbers (3000 year BC)
class Cuneiform extends StatelessWidget {
  /// All of the parameters are required and must not be null.
  const Cuneiform(
      {@required this.color,
      @required this.second,
      @required this.minute,
      @required this.hour})
      : assert(color != null);

  /// Arrow color.
  final Color color;

  final int second;
  final int minute;
  final int hour;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _CuneiformPainter(
            color: color,
            second: second,
            minute: minute,
            hour: hour,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _CuneiformPainter extends CustomPainter {
  _CuneiformPainter(
      {@required this.color,
      @required this.second,
      @required this.minute,
      @required this.hour})
      : assert(color != null),
        assert(second >= 0),
        assert(second <= 60),
        assert(minute >= 0),
        assert(minute <= 60),
        assert(hour >= 0),
        assert(hour <= 12);

  Color color;
  int second;
  int minute;
  int hour;

  double symbolHeight = 100.0;
  double symbolWidth = 60.0;

  // Don't like many numbers in code
  static const third = 1.0 / 3.0;
  static const half = 0.5;
  static const tens = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    symbolHeight = 0.25 * size.height;
    symbolWidth = symbolHeight * 3.0 / 5.0;
    paintSeconds(canvas, size);
    paintMinutes(canvas, size);
    paintHours(canvas, size);
  }

  void paintSeconds(Canvas canvas, Size size) {
    var x = size.width / 2 - symbolWidth;
    var y = size.height * 2 * third;

    paintBabylonianNumber(canvas, second, x, y);
  }

  void paintMinutes(Canvas canvas, Size size) {
    var x = size.width * 0.9 - symbolWidth * 2;
    var y = size.height * 1 / 6;
    paintBabylonianNumber(canvas, minute, x, y);
  }

  void paintHours(Canvas canvas, Size size) {
    var x = size.width * tens;
    var y = size.height * half * third;
    paintBabylonianNumber(canvas, hour, x, y);
  }

  /// Paint [number] % 10  and [number] ~/ 10 part
  void paintBabylonianNumber(Canvas canvas, int number, x, y) {
    var digit = number % 10;
    var dozen = number ~/ 10;
    paintDozen(canvas, dozen, x, y);
    paintDecimal(canvas, digit, x + symbolWidth, y);
  }

  /// Paint symbol for decimal part [dozen] (10 ... 50)
  void paintDozen(
    Canvas canvas,
    int dozen,
    double posX,
    double posY,
  ) {
    if (dozen == 0) {
      return;
    }

    canvas.save();
    canvas.translate(posX, posY);

    switch (dozen) {
      case 0:
        break;
      case 1:
      case 2:
      case 3:
        canvas.save();
        canvas.scale(1 / dozen, 1.0);
        // 1,2,3 is simple <<<
        for (int i = 0; i < dozen; ++i) {
          paintHorizontalTriangle(canvas);
          canvas.translate(symbolWidth, 0);
        }
        canvas.restore();
        break;

      case 4:
      case 5:
        canvas.save();
        canvas.scale(third, 1.0);
        paintHorizontalTriangle(canvas);

        canvas.translate(symbolWidth, 0);
        canvas.scale(1, half);
        // I have to group by pairs
        paintHorizontalTriangle(canvas);
        canvas.translate(0, symbolHeight);
        paintHorizontalTriangle(canvas);
        canvas.translate(symbolWidth, -symbolHeight);

        paintHorizontalTriangle(canvas);
        if (dozen == 5) {
          canvas.translate(0, symbolHeight);
          paintHorizontalTriangle(canvas);
        }
        canvas.restore();
        break;
    }
    canvas.restore();
  }

  /// Paint triangle. Left arrow.
  void paintHorizontalTriangle(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    var path = Path();

    var y = 0.0;
    var x = 0.0;
    var offsetX = 0;
    var offsetY = 0;

    path.moveTo(x + offsetX, y + symbolHeight * half);
    path.lineTo(x + symbolWidth - offsetX, y + offsetY);
    path.lineTo(x + symbolWidth * third, y + symbolHeight * half);
    path.lineTo(x + symbolWidth - offsetX, y + symbolHeight - offsetY);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Paint [digit] from 1 to 9.
  /// I don't know about sumerian zero.
  void paintDecimal(Canvas canvas, int digit, double posX, double posY) {
    if (digit == 0) {
      return;
    }
    canvas.save();
    canvas.translate(posX, posY);
    canvas.save();

    var scaleX = 1.0;
    if (digit == 2) {
      scaleX = half;
    } else if (digit >= 3) {
      scaleX = third;
    }

    var scaleY = 1 / (digit * third).ceil();
    canvas.scale(scaleX, scaleY);

    for (int i = 0; i < digit; ++i) {
      var shiftX = i % 3;
      var shiftY = i ~/ 3;
      canvas.save();
      canvas.translate(symbolWidth * shiftX, symbolHeight * shiftY);
      paintTriangle(canvas);
      canvas.restore();
    }
    canvas.restore();
    canvas.restore();
  }

  /// Triangle. Down arrow.
  void paintTriangle(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var x = 0.0;
    var y = 0.0;
    var path = Path();
    path.moveTo(x, y);

    path.lineTo(x + symbolWidth * half, y + symbolHeight * 0.05);
    path.lineTo(x + symbolWidth, y);
    path.lineTo(x + symbolWidth * 0.6, y + symbolHeight * 0.2);
    path.lineTo(x + symbolWidth * half, y + symbolHeight);
    path.lineTo(x + symbolWidth * 0.4, y + symbolHeight * 0.2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CuneiformPainter oldDelegate) {
    return true;
  }
}
