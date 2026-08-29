import 'package:flutter/material.dart';
import 'package:safeplace/theme/colors.dart';

class SafePlaceLogo extends StatelessWidget {
  const SafePlaceLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShieldPainter()),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shield = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..cubicTo(w * 0.68, h * 0.18, w * 0.84, h * 0.22, w * 0.88, h * 0.24)
      ..lineTo(w * 0.88, h * 0.52)
      ..cubicTo(w * 0.88, h * 0.72, w * 0.70, h * 0.86, w * 0.50, h * 0.94)
      ..cubicTo(w * 0.30, h * 0.86, w * 0.12, h * 0.72, w * 0.12, h * 0.52)
      ..lineTo(w * 0.12, h * 0.24)
      ..cubicTo(w * 0.16, h * 0.22, w * 0.32, h * 0.18, w * 0.50, h * 0.08)
      ..close();

    final fill = Paint()
      ..shader = SafePlaceColors.brand.createShader(
        Rect.fromLTWH(0, 0, w, h),
      );

    canvas.drawPath(shield, fill);

    final pin = Path()
      ..moveTo(w * 0.50, h * 0.58)
      ..cubicTo(w * 0.50, h * 0.58, w * 0.34, h * 0.46, w * 0.34, h * 0.36)
      ..cubicTo(w * 0.34, h * 0.27, w * 0.41, h * 0.22, w * 0.50, h * 0.22)
      ..cubicTo(w * 0.59, h * 0.22, w * 0.66, h * 0.27, w * 0.66, h * 0.36)
      ..cubicTo(w * 0.66, h * 0.46, w * 0.50, h * 0.58, w * 0.50, h * 0.58)
      ..close();

    final pinPaint = Paint()..color = SafePlaceColors.white;
    canvas.drawPath(pin, pinPaint);
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.35),
      w * 0.055,
      Paint()..color = SafePlaceColors.safeBlue,
    );

    final barPaint = Paint()..color = SafePlaceColors.white;
    void bar(double x, double top, double bh) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * x, h * top, w * 0.07, h * bh),
          Radius.circular(w * 0.02),
        ),
        barPaint,
      );
    }

    bar(0.385, 0.68, 0.12);
    bar(0.465, 0.64, 0.16);
    barPaint.color = const Color(0xFF93C5FD);
    bar(0.545, 0.60, 0.20);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SafePlaceWordmark extends StatelessWidget {
  const SafePlaceWordmark({super.key, this.fontSize = 36});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: -0.6,
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Safe', style: base.copyWith(color: SafePlaceColors.white)),
        ShaderMask(
          shaderCallback: (bounds) =>
              SafePlaceColors.wordmark.createShader(bounds),
          child: Text('Place', style: base.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
