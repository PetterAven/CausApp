import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _NatureLeavesPainter(animationValue: _controller.value),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _NatureLeavesPainter extends CustomPainter {
  final double animationValue;

  _NatureLeavesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Fondo con gradiente verde claro pastel (#E8F5E9 a blanco)
    final rect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFE8F5E9),
        const Color(0xFFF1F8E9),
        Colors.white,
      ],
    );
    paint.shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = null;

    // Configuración de hojas flotantes/cayendo suavemente con tonos de verde (#2E7D32)
    final leaves = [
      {'xStart': 0.1, 'speed': 0.9, 'size': 18.0, 'color': const Color(0xFF2E7D32).withValues(alpha: 0.18), 'phase': 0.0},
      {'xStart': 0.3, 'speed': 1.2, 'size': 14.0, 'color': const Color(0xFF43A047).withValues(alpha: 0.16), 'phase': 1.2},
      {'xStart': 0.5, 'speed': 0.8, 'size': 22.0, 'color': const Color(0xFF81C784).withValues(alpha: 0.15), 'phase': 2.5},
      {'xStart': 0.7, 'speed': 1.1, 'size': 16.0, 'color': const Color(0xFF1B5E20).withValues(alpha: 0.17), 'phase': 3.8},
      {'xStart': 0.85, 'speed': 1.0, 'size': 20.0, 'color': const Color(0xFF2E7D32).withValues(alpha: 0.14), 'phase': 4.5},
      {'xStart': 0.2, 'speed': 0.7, 'size': 15.0, 'color': const Color(0xFF66BB6A).withValues(alpha: 0.16), 'phase': 5.2},
    ];

    for (var leaf in leaves) {
      final xStart = leaf['xStart'] as double;
      final speed = leaf['speed'] as double;
      final leafSize = leaf['size'] as double;
      final color = leaf['color'] as Color;
      final phase = leaf['phase'] as double;

      // Calcular posición Y ciclando de arriba a abajo
      final progress = ((animationValue * speed + (phase / (2 * math.pi))) % 1.0);
      final y = progress * (size.height + 60) - 30;

      // Movimiento ondulatorio lateral (efecto de caída de hoja con viento suave)
      final sway = math.sin((animationValue * 2 * math.pi * 2) + phase) * 25.0;
      final x = (size.width * xStart) + sway;

      // Rotación suave de la hoja
      final rotation = math.sin((animationValue * 2 * math.pi) + phase) * 0.8;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = color;
      
      // Dibujar forma de hoja orgánica estilizada
      final path = Path();
      path.moveTo(0, -leafSize);
      path.quadraticBezierTo(leafSize * 0.8, -leafSize * 0.3, 0, leafSize);
      path.quadraticBezierTo(-leafSize * 0.8, -leafSize * 0.3, 0, -leafSize);
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NatureLeavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
