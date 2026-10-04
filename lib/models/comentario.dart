import 'package:flutter/foundation.dart';

@immutable
class Comentario {
  final String id;
  final String reporteId;
  final String userId;
  final String texto;
  final DateTime createdAt;

  const Comentario({
    required this.id,
    required this.reporteId,
    required this.userId,
    required this.texto,
    required this.createdAt,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id']?.toString() ?? '',
      reporteId: json['reporte_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      texto: json['texto'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporte_id': reporteId,
      'user_id': userId,
      'texto': texto,
    };
  }
}
