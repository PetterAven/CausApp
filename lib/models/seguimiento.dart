import 'package:flutter/foundation.dart';

@immutable
class Seguimiento {
  final String id;
  final String reporteId;
  final String liderId;
  final String estadoNuevo;
  final String nota;
  final DateTime createdAt;

  const Seguimiento({
    required this.id,
    required this.reporteId,
    required this.liderId,
    required this.estadoNuevo,
    required this.nota,
    required this.createdAt,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: json['id']?.toString() ?? '',
      reporteId: json['reporte_id']?.toString() ?? '',
      liderId: json['lider_id']?.toString() ?? '',
      estadoNuevo: json['estado_nuevo'] as String? ?? '',
      nota: json['nota'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporte_id': reporteId,
      'lider_id': liderId,
      'estado_nuevo': estadoNuevo,
      'nota': nota,
    };
  }
}
