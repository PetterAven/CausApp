import 'package:flutter/material.dart';
import 'dart:math' as math;

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = math.min(w, h) / 2;
    final strokeWidth = radius * 0.38;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // 1. Red arc (Top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 0.5, false, paint);

    // 2. Yellow arc (Bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 1.25, math.pi * 0.5, false, paint);

    // 3. Green arc (Bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 1.75, math.pi * 0.5, false, paint);

    // 4. Blue arc (Top-right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.5, false, paint);

    // Blue horizontal bar for the 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(center.dx - 1, center.dy - strokeWidth / 2, radius + 1, strokeWidth),
      barPaint,
    );

    // Inner cutout to make it look like a crisp 'G' ring
    // Small inner circle mask/cutout if needed, or keeping it clean.
    // Let's draw a small white rect in the inner left if needed, 
    // but the arc layout already looks great. Let's add the inner crossbar cutout.
    final cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Vertical cutout in the middle-right to form the G opening
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy, radius, strokeWidth * 0.8),
      cutoutPaint,
    );

    // Redraw blue top-right arc portion or bar adjustment if needed.
    // Actually, let's keep it simple and extremely sharp.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
