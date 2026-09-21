import 'package:flutter/foundation.dart';

@immutable
class Donacion {
  final String id;
  final String usuarioId;
  final String? jornadaId; // Opcional, si es donación directa a una jornada
  final String tipo; // 'dinero', 'articulo'
  final double? monto;
  final String? articuloDescripcion;
  final int? cantidad;
  final String metodoPago; // 'tarjeta', 'transferencia', 'qr', 'articulo'
  final String estado; // 'pendiente', 'completada', 'fallida'
  final DateTime createdAt;

  const Donacion({
    required this.id,
    required this.usuarioId,
    this.jornadaId,
    required this.tipo,
    this.monto,
    this.articuloDescripcion,
    this.cantidad,
    required this.metodoPago,
    required this.estado,
    required this.createdAt,
  });

  factory Donacion.fromJson(Map<String, dynamic> json) {
    return Donacion(
      id: json['id'].toString(),
      usuarioId: json['usuario_id'].toString(),
      jornadaId: json['jornada_id']?.toString(),
      tipo: json['tipo'] as String? ?? 'dinero',
      monto: json['monto'] != null ? (json['monto'] as num).toDouble() : null,
      articuloDescripcion: json['articulo_descripcion'] as String?,
      cantidad: json['cantidad'] as int?,
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
      'tipo': tipo,
      if (monto != null) 'monto': monto,
      if (articuloDescripcion != null) 'articulo_descripcion': articuloDescripcion,
      if (cantidad != null) 'cantidad': cantidad,
      'metodo_pago': metodoPago,
      'estado': estado,
    };
  }
}
