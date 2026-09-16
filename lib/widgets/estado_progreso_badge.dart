import 'package:flutter/material.dart';

class EstadoProgresoBadge extends StatelessWidget {
  final String estadoProgreso;
  final bool showLabel;

  const EstadoProgresoBadge({
    super.key,
    required this.estadoProgreso,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (estadoProgreso) {
      case 'en_proceso':
        color = const Color(0xFFF9A825); // Amarillo
        label = 'En proceso';
        break;
      case 'completada':
        color = const Color(0xFF2E7D32); // Verde
        label = 'Completada';
        break;
      case 'pendiente':
      default:
        color = const Color(0xFFD32F2F); // Rojo
        label = 'Pendiente';
        break;
    }

    if (!showLabel) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
