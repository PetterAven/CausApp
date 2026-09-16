import 'package:flutter/foundation.dart';

@immutable
class MensajeRecurso {
  final String id;
  final String recursoId;
  final String usuarioId;
  final String mensaje;
  final DateTime fecha;

  const MensajeRecurso({
    required this.id,
    required this.recursoId,
    required this.usuarioId,
    required this.mensaje,
    required this.fecha,
  });

  factory MensajeRecurso.fromJson(Map<String, dynamic> json) {
    return MensajeRecurso(
      id: json['id'].toString(),
      recursoId: json['recurso_id'].toString(),
      usuarioId: json['usuario_id'].toString(),
      mensaje: json['mensaje'] as String,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'recurso_id': recursoId,
      'usuario_id': usuarioId,
      'mensaje': mensaje,
    };
  }
}
