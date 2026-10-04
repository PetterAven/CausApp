import 'package:flutter/foundation.dart';

@immutable
class Reporte {
  final String id;
  final String userId;
  final String categoria; // Fuga de agua, Basura, Bache, Alumbrado público, Drenaje, Otros
  final String descripcion;
  final List<String> fotos;
  final double latitud;
  final double longitud;
  final String estado; // pendiente | en_seguimiento | canalizado | resuelto
  final int apoyos;
  final DateTime createdAt;

  const Reporte({
    required this.id,
    required this.userId,
    required this.categoria,
    required this.descripcion,
    required this.fotos,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.apoyos,
    required this.createdAt,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoria: json['categoria'] as String? ?? 'Otros',
      descripcion: json['descripcion'] as String? ?? '',
      fotos: json['fotos'] != null
          ? List<String>.from((json['fotos'] as List).map((e) => e.toString()))
          : [],
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] as String? ?? 'pendiente',
      apoyos: (json['apoyos'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'categoria': categoria,
      'descripcion': descripcion,
      'fotos': fotos,
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado,
      'apoyos': apoyos,
    };
  }

  Reporte copyWith({
    String? id,
    String? userId,
    String? categoria,
    String? descripcion,
    List<String>? fotos,
    double? latitud,
    double? longitud,
    String? estado,
    int? apoyos,
    DateTime? createdAt,
  }) {
    return Reporte(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      fotos: fotos ?? this.fotos,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      estado: estado ?? this.estado,
      apoyos: apoyos ?? this.apoyos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
