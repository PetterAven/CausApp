import 'package:flutter/foundation.dart';

@immutable
class Inscripcion {
  final String id;
  final String jornadaId;
  final String voluntarioId;
  final DateTime createdAt;

  const Inscripcion({
    required this.id,
    required this.jornadaId,
    required this.voluntarioId,
    required this.createdAt,
  });

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      id: json['id'].toString(),
      jornadaId: json['jornada_id'].toString(),
      voluntarioId: json['voluntario_id'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jornada_id': jornadaId,
      'voluntario_id': voluntarioId,
    };
  }
}
