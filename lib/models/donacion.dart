import 'package:flutter/foundation.dart';

@immutable
class Donacion {
  final String id;
  final String usuarioId;
  final String? jornadaId; // Opcional, si es donación directa a una jornada
  final double monto;
  final String metodoPago; // 'tarjeta', 'transferencia', 'qr'
  final String estado; // 'pendiente', 'completada', 'fallida'
  final DateTime createdAt;

  const Donacion({
    required this.id,
    required this.usuarioId,
    this.jornadaId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    required this.createdAt,
  });

  factory Donacion.fromJson(Map<String, dynamic> json) {
    return Donacion(
      id: json['id'].toString(),
      usuarioId: json['usuario_id'].toString(),
      jornadaId: json['jornada_id']?.toString(),
      monto: (json['monto'] as num).toDouble(),
      metodoPago: json['metodo_pago'] as String? ?? 'tarjeta',
      estado: json['estado'] as String? ?? 'pendiente',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      if (jornadaId != null) 'jornada_id': jornadaId,
      'monto': monto,
      'metodo_pago': metodoPago,
      'estado': estado,
    };
  }
}
