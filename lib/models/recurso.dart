import 'package:flutter/foundation.dart';

@immutable
class Recurso {
  final String id;
  final String? jornadaId;
  final String usuarioId;
  final String nombreArticulo;
  final int cantidad;
  final String descripcion;
  final String estado; // 'disponible', 'prestado', 'no_disponible'
  final DateTime fechaPublicacion;

  const Recurso({
    required this.id,
    this.jornadaId,
    required this.usuarioId,
    required this.nombreArticulo,
    required this.cantidad,
    required this.descripcion,
    required this.estado,
    required this.fechaPublicacion,
  });

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'].toString(),
      jornadaId: json['jornada_id']?.toString(),
      usuarioId: json['usuario_id'].toString(),
      nombreArticulo: json['nombre_articulo'] as String,
      cantidad: json['cantidad'] as int? ?? 1,
      descripcion: json['descripcion'] as String? ?? '',
      estado: json['estado'] as String? ?? 'disponible',
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'jornada_id': jornadaId,
      'usuario_id': usuarioId,
      'nombre_articulo': nombreArticulo,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  Recurso copyWith({
    String? id,
    String? jornadaId,
    String? usuarioId,
    String? nombreArticulo,
    int? cantidad,
    String? descripcion,
    String? estado,
    DateTime? fechaPublicacion,
  }) {
    return Recurso(
      id: id ?? this.id,
      jornadaId: jornadaId ?? this.jornadaId,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreArticulo: nombreArticulo ?? this.nombreArticulo,
      cantidad: cantidad ?? this.cantidad,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
    );
  }
}
