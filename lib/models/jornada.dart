import 'package:flutter/foundation.dart';

@immutable
class Jornada {
  final String id;
  final String organizadorId;
  final String titulo;
  final String categoria;
  final String? categoriaPersonalizada;
  final String descripcion;
  final String fecha; // Formato YYYY-MM-DD
  final String hora;  // Formato HH:mm
  final double latitud;
  final double longitud;
  final String direccionReferencia;
  final int? cupoVoluntarios; // null = sin límite
  final String estado; // 'activa', 'cancelada', 'finalizada'
  final String estadoProgreso; // 'pendiente', 'en_proceso', 'completada'
  final List<String> herramientasNecesarias;
  final DateTime createdAt;

  const Jornada({
    required this.id,
    required this.organizadorId,
    required this.titulo,
    required this.categoria,
    this.categoriaPersonalizada,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.latitud,
    required this.longitud,
    required this.direccionReferencia,
    this.cupoVoluntarios,
    required this.estado,
    required this.estadoProgreso,
    this.herramientasNecesarias = const [],
    required this.createdAt,
  });

  // Constructor para crear una Jornada desde un mapa JSON (Supabase)
  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      id: json['id']?.toString() ?? '',
      organizadorId: json['organizador_id']?.toString() ?? '',
      titulo: json['titulo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? 'Limpieza',
      categoriaPersonalizada: json['categoria_personalizada'] as String?,
      descripcion: json['descripcion'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
      hora: json['hora'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      direccionReferencia: json['direccion_referencia'] as String? ?? '',
      cupoVoluntarios: json['cupo_voluntarios'] as int?,
      estado: json['estado'] as String? ?? 'activa',
      estadoProgreso: json['estado_progreso'] as String? ?? 'pendiente',
      herramientasNecesarias: json['herramientas_necesarias'] != null
          ? List<String>.from((json['herramientas_necesarias'] as List).map((e) => e.toString()))
          : [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  // Convertir Jornada a mapa JSON para insertar/actualizar en Supabase
  Map<String, dynamic> toJson() {
    return {
      'organizador_id': organizadorId,
      'titulo': titulo,
      'categoria': categoria,
      'categoria_personalizada': categoriaPersonalizada,
      'descripcion': descripcion,
      'fecha': fecha,
      'hora': hora,
      'latitud': latitud,
      'longitud': longitud,
      'direccion_referencia': direccionReferencia,
      'cupo_voluntarios': cupoVoluntarios,
      'estado': estado,
      'estado_progreso': estadoProgreso,
      'herramientas_necesarias': herramientasNecesarias,
    };
  }

  Jornada copyWith({
    String? id,
    String? organizadorId,
    String? titulo,
    String? categoria,
    String? categoriaPersonalizada,
    String? descripcion,
    String? fecha,
    String? hora,
    double? latitud,
    double? longitud,
    String? direccionReferencia,
    int? cupoVoluntarios,
    String? estado,
    String? estadoProgreso,
    List<String>? herramientasNecesarias,
    DateTime? createdAt,
  }) {
    return Jornada(
      id: id ?? this.id,
      organizadorId: organizadorId ?? this.organizadorId,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      categoriaPersonalizada: categoriaPersonalizada ?? this.categoriaPersonalizada,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccionReferencia: direccionReferencia ?? this.direccionReferencia,
      cupoVoluntarios: cupoVoluntarios ?? this.cupoVoluntarios,
      estado: estado ?? this.estado,
      estadoProgreso: estadoProgreso ?? this.estadoProgreso,
      herramientasNecesarias: herramientasNecesarias ?? this.herramientasNecesarias,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
