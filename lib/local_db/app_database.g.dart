// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JornadasLocalTable extends JornadasLocal
    with TableInfo<$JornadasLocalTable, JornadaLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JornadasLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizadorIdMeta = const VerificationMeta(
    'organizadorId',
  );
  @override
  late final GeneratedColumn<String> organizadorId = GeneratedColumn<String>(
    'organizador_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaPersonalizadaMeta =
      const VerificationMeta('categoriaPersonalizada');
  @override
  late final GeneratedColumn<String> categoriaPersonalizada =
      GeneratedColumn<String>(
        'categoria_personalizada',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<String> hora = GeneratedColumn<String>(
    'hora',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _direccionReferenciaMeta =
      const VerificationMeta('direccionReferencia');
  @override
  late final GeneratedColumn<String> direccionReferencia =
      GeneratedColumn<String>(
        'direccion_referencia',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cupoVoluntariosMeta = const VerificationMeta(
    'cupoVoluntarios',
  );
  @override
  late final GeneratedColumn<int> cupoVoluntarios = GeneratedColumn<int>(
    'cupo_voluntarios',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('activa'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizadorId,
    titulo,
    categoria,
    categoriaPersonalizada,
    descripcion,
    fecha,
    hora,
    latitud,
    longitud,
    direccionReferencia,
    cupoVoluntarios,
    estado,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jornadas_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<JornadaLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organizador_id')) {
      context.handle(
        _organizadorIdMeta,
        organizadorId.isAcceptableOrUnknown(
          data['organizador_id']!,
          _organizadorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizadorIdMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('categoria_personalizada')) {
      context.handle(
        _categoriaPersonalizadaMeta,
        categoriaPersonalizada.isAcceptableOrUnknown(
          data['categoria_personalizada']!,
          _categoriaPersonalizadaMeta,
        ),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudMeta);
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudMeta);
    }
    if (data.containsKey('direccion_referencia')) {
      context.handle(
        _direccionReferenciaMeta,
        direccionReferencia.isAcceptableOrUnknown(
          data['direccion_referencia']!,
          _direccionReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('cupo_voluntarios')) {
      context.handle(
        _cupoVoluntariosMeta,
        cupoVoluntarios.isAcceptableOrUnknown(
          data['cupo_voluntarios']!,
          _cupoVoluntariosMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JornadaLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JornadaLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organizador_id'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      categoriaPersonalizada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_personalizada'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora'],
      )!,
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      )!,
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      )!,
      direccionReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion_referencia'],
      ),
      cupoVoluntarios: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cupo_voluntarios'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $JornadasLocalTable createAlias(String alias) {
    return $JornadasLocalTable(attachedDatabase, alias);
  }
}

class JornadaLocal extends DataClass implements Insertable<JornadaLocal> {
  final String id;
  final String organizadorId;
  final String titulo;
  final String categoria;
  final String? categoriaPersonalizada;
  final String? descripcion;
  final String fecha;
  final String hora;
  final double latitud;
  final double longitud;
  final String? direccionReferencia;
  final int? cupoVoluntarios;
  final String estado;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const JornadaLocal({
    required this.id,
    required this.organizadorId,
    required this.titulo,
    required this.categoria,
    this.categoriaPersonalizada,
    this.descripcion,
    required this.fecha,
    required this.hora,
    required this.latitud,
    required this.longitud,
    this.direccionReferencia,
    this.cupoVoluntarios,
    required this.estado,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organizador_id'] = Variable<String>(organizadorId);
    map['titulo'] = Variable<String>(titulo);
    map['categoria'] = Variable<String>(categoria);
    if (!nullToAbsent || categoriaPersonalizada != null) {
      map['categoria_personalizada'] = Variable<String>(categoriaPersonalizada);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['fecha'] = Variable<String>(fecha);
    map['hora'] = Variable<String>(hora);
    map['latitud'] = Variable<double>(latitud);
    map['longitud'] = Variable<double>(longitud);
    if (!nullToAbsent || direccionReferencia != null) {
      map['direccion_referencia'] = Variable<String>(direccionReferencia);
    }
    if (!nullToAbsent || cupoVoluntarios != null) {
      map['cupo_voluntarios'] = Variable<int>(cupoVoluntarios);
    }
    map['estado'] = Variable<String>(estado);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  JornadasLocalCompanion toCompanion(bool nullToAbsent) {
    return JornadasLocalCompanion(
      id: Value(id),
      organizadorId: Value(organizadorId),
      titulo: Value(titulo),
      categoria: Value(categoria),
      categoriaPersonalizada: categoriaPersonalizada == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaPersonalizada),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fecha: Value(fecha),
      hora: Value(hora),
      latitud: Value(latitud),
      longitud: Value(longitud),
      direccionReferencia: direccionReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(direccionReferencia),
      cupoVoluntarios: cupoVoluntarios == null && nullToAbsent
          ? const Value.absent()
          : Value(cupoVoluntarios),
      estado: Value(estado),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory JornadaLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JornadaLocal(
      id: serializer.fromJson<String>(json['id']),
      organizadorId: serializer.fromJson<String>(json['organizadorId']),
      titulo: serializer.fromJson<String>(json['titulo']),
      categoria: serializer.fromJson<String>(json['categoria']),
      categoriaPersonalizada: serializer.fromJson<String?>(
        json['categoriaPersonalizada'],
      ),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fecha: serializer.fromJson<String>(json['fecha']),
      hora: serializer.fromJson<String>(json['hora']),
      latitud: serializer.fromJson<double>(json['latitud']),
      longitud: serializer.fromJson<double>(json['longitud']),
      direccionReferencia: serializer.fromJson<String?>(
        json['direccionReferencia'],
      ),
      cupoVoluntarios: serializer.fromJson<int?>(json['cupoVoluntarios']),
      estado: serializer.fromJson<String>(json['estado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizadorId': serializer.toJson<String>(organizadorId),
      'titulo': serializer.toJson<String>(titulo),
      'categoria': serializer.toJson<String>(categoria),
      'categoriaPersonalizada': serializer.toJson<String?>(
        categoriaPersonalizada,
      ),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fecha': serializer.toJson<String>(fecha),
      'hora': serializer.toJson<String>(hora),
      'latitud': serializer.toJson<double>(latitud),
      'longitud': serializer.toJson<double>(longitud),
      'direccionReferencia': serializer.toJson<String?>(direccionReferencia),
      'cupoVoluntarios': serializer.toJson<int?>(cupoVoluntarios),
      'estado': serializer.toJson<String>(estado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  JornadaLocal copyWith({
    String? id,
    String? organizadorId,
    String? titulo,
    String? categoria,
    Value<String?> categoriaPersonalizada = const Value.absent(),
    Value<String?> descripcion = const Value.absent(),
    String? fecha,
    String? hora,
    double? latitud,
    double? longitud,
    Value<String?> direccionReferencia = const Value.absent(),
    Value<int?> cupoVoluntarios = const Value.absent(),
    String? estado,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => JornadaLocal(
    id: id ?? this.id,
    organizadorId: organizadorId ?? this.organizadorId,
    titulo: titulo ?? this.titulo,
    categoria: categoria ?? this.categoria,
    categoriaPersonalizada: categoriaPersonalizada.present
        ? categoriaPersonalizada.value
        : this.categoriaPersonalizada,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    fecha: fecha ?? this.fecha,
    hora: hora ?? this.hora,
    latitud: latitud ?? this.latitud,
    longitud: longitud ?? this.longitud,
    direccionReferencia: direccionReferencia.present
        ? direccionReferencia.value
        : this.direccionReferencia,
    cupoVoluntarios: cupoVoluntarios.present
        ? cupoVoluntarios.value
        : this.cupoVoluntarios,
    estado: estado ?? this.estado,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  JornadaLocal copyWithCompanion(JornadasLocalCompanion data) {
    return JornadaLocal(
      id: data.id.present ? data.id.value : this.id,
      organizadorId: data.organizadorId.present
          ? data.organizadorId.value
          : this.organizadorId,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      categoriaPersonalizada: data.categoriaPersonalizada.present
          ? data.categoriaPersonalizada.value
          : this.categoriaPersonalizada,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      hora: data.hora.present ? data.hora.value : this.hora,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      direccionReferencia: data.direccionReferencia.present
          ? data.direccionReferencia.value
          : this.direccionReferencia,
      cupoVoluntarios: data.cupoVoluntarios.present
          ? data.cupoVoluntarios.value
          : this.cupoVoluntarios,
      estado: data.estado.present ? data.estado.value : this.estado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JornadaLocal(')
          ..write('id: $id, ')
          ..write('organizadorId: $organizadorId, ')
          ..write('titulo: $titulo, ')
          ..write('categoria: $categoria, ')
          ..write('categoriaPersonalizada: $categoriaPersonalizada, ')
          ..write('descripcion: $descripcion, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('direccionReferencia: $direccionReferencia, ')
          ..write('cupoVoluntarios: $cupoVoluntarios, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizadorId,
    titulo,
    categoria,
    categoriaPersonalizada,
    descripcion,
    fecha,
    hora,
    latitud,
    longitud,
    direccionReferencia,
    cupoVoluntarios,
    estado,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JornadaLocal &&
          other.id == this.id &&
          other.organizadorId == this.organizadorId &&
          other.titulo == this.titulo &&
          other.categoria == this.categoria &&
          other.categoriaPersonalizada == this.categoriaPersonalizada &&
          other.descripcion == this.descripcion &&
          other.fecha == this.fecha &&
          other.hora == this.hora &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.direccionReferencia == this.direccionReferencia &&
          other.cupoVoluntarios == this.cupoVoluntarios &&
          other.estado == this.estado &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class JornadasLocalCompanion extends UpdateCompanion<JornadaLocal> {
  final Value<String> id;
  final Value<String> organizadorId;
  final Value<String> titulo;
  final Value<String> categoria;
  final Value<String?> categoriaPersonalizada;
  final Value<String?> descripcion;
  final Value<String> fecha;
  final Value<String> hora;
  final Value<double> latitud;
  final Value<double> longitud;
  final Value<String?> direccionReferencia;
  final Value<int?> cupoVoluntarios;
  final Value<String> estado;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const JornadasLocalCompanion({
    this.id = const Value.absent(),
    this.organizadorId = const Value.absent(),
    this.titulo = const Value.absent(),
    this.categoria = const Value.absent(),
    this.categoriaPersonalizada = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.direccionReferencia = const Value.absent(),
    this.cupoVoluntarios = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JornadasLocalCompanion.insert({
    required String id,
    required String organizadorId,
    required String titulo,
    required String categoria,
    this.categoriaPersonalizada = const Value.absent(),
    this.descripcion = const Value.absent(),
    required String fecha,
    required String hora,
    required double latitud,
    required double longitud,
    this.direccionReferencia = const Value.absent(),
    this.cupoVoluntarios = const Value.absent(),
    this.estado = const Value.absent(),
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizadorId = Value(organizadorId),
       titulo = Value(titulo),
       categoria = Value(categoria),
       fecha = Value(fecha),
       hora = Value(hora),
       latitud = Value(latitud),
       longitud = Value(longitud),
       createdAt = Value(createdAt);
  static Insertable<JornadaLocal> custom({
    Expression<String>? id,
    Expression<String>? organizadorId,
    Expression<String>? titulo,
    Expression<String>? categoria,
    Expression<String>? categoriaPersonalizada,
    Expression<String>? descripcion,
    Expression<String>? fecha,
    Expression<String>? hora,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<String>? direccionReferencia,
    Expression<int>? cupoVoluntarios,
    Expression<String>? estado,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizadorId != null) 'organizador_id': organizadorId,
      if (titulo != null) 'titulo': titulo,
      if (categoria != null) 'categoria': categoria,
      if (categoriaPersonalizada != null)
        'categoria_personalizada': categoriaPersonalizada,
      if (descripcion != null) 'descripcion': descripcion,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (direccionReferencia != null)
        'direccion_referencia': direccionReferencia,
      if (cupoVoluntarios != null) 'cupo_voluntarios': cupoVoluntarios,
      if (estado != null) 'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JornadasLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? organizadorId,
    Value<String>? titulo,
    Value<String>? categoria,
    Value<String?>? categoriaPersonalizada,
    Value<String?>? descripcion,
    Value<String>? fecha,
    Value<String>? hora,
    Value<double>? latitud,
    Value<double>? longitud,
    Value<String?>? direccionReferencia,
    Value<int?>? cupoVoluntarios,
    Value<String>? estado,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return JornadasLocalCompanion(
      id: id ?? this.id,
      organizadorId: organizadorId ?? this.organizadorId,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      categoriaPersonalizada:
          categoriaPersonalizada ?? this.categoriaPersonalizada,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccionReferencia: direccionReferencia ?? this.direccionReferencia,
      cupoVoluntarios: cupoVoluntarios ?? this.cupoVoluntarios,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizadorId.present) {
      map['organizador_id'] = Variable<String>(organizadorId.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (categoriaPersonalizada.present) {
      map['categoria_personalizada'] = Variable<String>(
        categoriaPersonalizada.value,
      );
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (hora.present) {
      map['hora'] = Variable<String>(hora.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (direccionReferencia.present) {
      map['direccion_referencia'] = Variable<String>(direccionReferencia.value);
    }
    if (cupoVoluntarios.present) {
      map['cupo_voluntarios'] = Variable<int>(cupoVoluntarios.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JornadasLocalCompanion(')
          ..write('id: $id, ')
          ..write('organizadorId: $organizadorId, ')
          ..write('titulo: $titulo, ')
          ..write('categoria: $categoria, ')
          ..write('categoriaPersonalizada: $categoriaPersonalizada, ')
          ..write('descripcion: $descripcion, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('direccionReferencia: $direccionReferencia, ')
          ..write('cupoVoluntarios: $cupoVoluntarios, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InscripcionesLocalTable extends InscripcionesLocal
    with TableInfo<$InscripcionesLocalTable, InscripcionLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InscripcionesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jornadaIdMeta = const VerificationMeta(
    'jornadaId',
  );
  @override
  late final GeneratedColumn<String> jornadaId = GeneratedColumn<String>(
    'jornada_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voluntarioIdMeta = const VerificationMeta(
    'voluntarioId',
  );
  @override
  late final GeneratedColumn<String> voluntarioId = GeneratedColumn<String>(
    'voluntario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jornadaId,
    voluntarioId,
    createdAt,
    pendingSync,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inscripciones_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<InscripcionLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jornada_id')) {
      context.handle(
        _jornadaIdMeta,
        jornadaId.isAcceptableOrUnknown(data['jornada_id']!, _jornadaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jornadaIdMeta);
    }
    if (data.containsKey('voluntario_id')) {
      context.handle(
        _voluntarioIdMeta,
        voluntarioId.isAcceptableOrUnknown(
          data['voluntario_id']!,
          _voluntarioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voluntarioIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jornadaId, voluntarioId};
  @override
  InscripcionLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InscripcionLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      jornadaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jornada_id'],
      )!,
      voluntarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voluntario_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $InscripcionesLocalTable createAlias(String alias) {
    return $InscripcionesLocalTable(attachedDatabase, alias);
  }
}

class InscripcionLocal extends DataClass
    implements Insertable<InscripcionLocal> {
  final String? id;
  final String jornadaId;
  final String voluntarioId;
  final DateTime createdAt;
  final bool pendingSync;
  final bool isDeleted;
  const InscripcionLocal({
    this.id,
    required this.jornadaId,
    required this.voluntarioId,
    required this.createdAt,
    required this.pendingSync,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['jornada_id'] = Variable<String>(jornadaId);
    map['voluntario_id'] = Variable<String>(voluntarioId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  InscripcionesLocalCompanion toCompanion(bool nullToAbsent) {
    return InscripcionesLocalCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      jornadaId: Value(jornadaId),
      voluntarioId: Value(voluntarioId),
      createdAt: Value(createdAt),
      pendingSync: Value(pendingSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory InscripcionLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InscripcionLocal(
      id: serializer.fromJson<String?>(json['id']),
      jornadaId: serializer.fromJson<String>(json['jornadaId']),
      voluntarioId: serializer.fromJson<String>(json['voluntarioId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String?>(id),
      'jornadaId': serializer.toJson<String>(jornadaId),
      'voluntarioId': serializer.toJson<String>(voluntarioId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  InscripcionLocal copyWith({
    Value<String?> id = const Value.absent(),
    String? jornadaId,
    String? voluntarioId,
    DateTime? createdAt,
    bool? pendingSync,
    bool? isDeleted,
  }) => InscripcionLocal(
    id: id.present ? id.value : this.id,
    jornadaId: jornadaId ?? this.jornadaId,
    voluntarioId: voluntarioId ?? this.voluntarioId,
    createdAt: createdAt ?? this.createdAt,
    pendingSync: pendingSync ?? this.pendingSync,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  InscripcionLocal copyWithCompanion(InscripcionesLocalCompanion data) {
    return InscripcionLocal(
      id: data.id.present ? data.id.value : this.id,
      jornadaId: data.jornadaId.present ? data.jornadaId.value : this.jornadaId,
      voluntarioId: data.voluntarioId.present
          ? data.voluntarioId.value
          : this.voluntarioId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InscripcionLocal(')
          ..write('id: $id, ')
          ..write('jornadaId: $jornadaId, ')
          ..write('voluntarioId: $voluntarioId, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jornadaId,
    voluntarioId,
    createdAt,
    pendingSync,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InscripcionLocal &&
          other.id == this.id &&
          other.jornadaId == this.jornadaId &&
          other.voluntarioId == this.voluntarioId &&
          other.createdAt == this.createdAt &&
          other.pendingSync == this.pendingSync &&
          other.isDeleted == this.isDeleted);
}

class InscripcionesLocalCompanion extends UpdateCompanion<InscripcionLocal> {
  final Value<String?> id;
  final Value<String> jornadaId;
  final Value<String> voluntarioId;
  final Value<DateTime> createdAt;
  final Value<bool> pendingSync;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const InscripcionesLocalCompanion({
    this.id = const Value.absent(),
    this.jornadaId = const Value.absent(),
    this.voluntarioId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InscripcionesLocalCompanion.insert({
    this.id = const Value.absent(),
    required String jornadaId,
    required String voluntarioId,
    required DateTime createdAt,
    this.pendingSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jornadaId = Value(jornadaId),
       voluntarioId = Value(voluntarioId),
       createdAt = Value(createdAt);
  static Insertable<InscripcionLocal> custom({
    Expression<String>? id,
    Expression<String>? jornadaId,
    Expression<String>? voluntarioId,
    Expression<DateTime>? createdAt,
    Expression<bool>? pendingSync,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jornadaId != null) 'jornada_id': jornadaId,
      if (voluntarioId != null) 'voluntario_id': voluntarioId,
      if (createdAt != null) 'created_at': createdAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InscripcionesLocalCompanion copyWith({
    Value<String?>? id,
    Value<String>? jornadaId,
    Value<String>? voluntarioId,
    Value<DateTime>? createdAt,
    Value<bool>? pendingSync,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return InscripcionesLocalCompanion(
      id: id ?? this.id,
      jornadaId: jornadaId ?? this.jornadaId,
      voluntarioId: voluntarioId ?? this.voluntarioId,
      createdAt: createdAt ?? this.createdAt,
      pendingSync: pendingSync ?? this.pendingSync,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jornadaId.present) {
      map['jornada_id'] = Variable<String>(jornadaId.value);
    }
    if (voluntarioId.present) {
      map['voluntario_id'] = Variable<String>(voluntarioId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InscripcionesLocalCompanion(')
          ..write('id: $id, ')
          ..write('jornadaId: $jornadaId, ')
          ..write('voluntarioId: $voluntarioId, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JornadasLocalTable jornadasLocal = $JornadasLocalTable(this);
  late final $InscripcionesLocalTable inscripcionesLocal =
      $InscripcionesLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jornadasLocal,
    inscripcionesLocal,
  ];
}

typedef $$JornadasLocalTableCreateCompanionBuilder =
    JornadasLocalCompanion Function({
      required String id,
      required String organizadorId,
      required String titulo,
      required String categoria,
      Value<String?> categoriaPersonalizada,
      Value<String?> descripcion,
      required String fecha,
      required String hora,
      required double latitud,
      required double longitud,
      Value<String?> direccionReferencia,
      Value<int?> cupoVoluntarios,
      Value<String> estado,
      required DateTime createdAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$JornadasLocalTableUpdateCompanionBuilder =
    JornadasLocalCompanion Function({
      Value<String> id,
      Value<String> organizadorId,
      Value<String> titulo,
      Value<String> categoria,
      Value<String?> categoriaPersonalizada,
      Value<String?> descripcion,
      Value<String> fecha,
      Value<String> hora,
      Value<double> latitud,
      Value<double> longitud,
      Value<String?> direccionReferencia,
      Value<int?> cupoVoluntarios,
      Value<String> estado,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$JornadasLocalTableFilterComposer
    extends Composer<_$AppDatabase, $JornadasLocalTable> {
  $$JornadasLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizadorId => $composableBuilder(
    column: $table.organizadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriaPersonalizada => $composableBuilder(
    column: $table.categoriaPersonalizada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccionReferencia => $composableBuilder(
    column: $table.direccionReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cupoVoluntarios => $composableBuilder(
    column: $table.cupoVoluntarios,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JornadasLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $JornadasLocalTable> {
  $$JornadasLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizadorId => $composableBuilder(
    column: $table.organizadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriaPersonalizada => $composableBuilder(
    column: $table.categoriaPersonalizada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccionReferencia => $composableBuilder(
    column: $table.direccionReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cupoVoluntarios => $composableBuilder(
    column: $table.cupoVoluntarios,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JornadasLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $JornadasLocalTable> {
  $$JornadasLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizadorId => $composableBuilder(
    column: $table.organizadorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get categoriaPersonalizada => $composableBuilder(
    column: $table.categoriaPersonalizada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<String> get direccionReferencia => $composableBuilder(
    column: $table.direccionReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cupoVoluntarios => $composableBuilder(
    column: $table.cupoVoluntarios,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$JornadasLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JornadasLocalTable,
          JornadaLocal,
          $$JornadasLocalTableFilterComposer,
          $$JornadasLocalTableOrderingComposer,
          $$JornadasLocalTableAnnotationComposer,
          $$JornadasLocalTableCreateCompanionBuilder,
          $$JornadasLocalTableUpdateCompanionBuilder,
          (
            JornadaLocal,
            BaseReferences<_$AppDatabase, $JornadasLocalTable, JornadaLocal>,
          ),
          JornadaLocal,
          PrefetchHooks Function()
        > {
  $$JornadasLocalTableTableManager(_$AppDatabase db, $JornadasLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JornadasLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JornadasLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JornadasLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizadorId = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String?> categoriaPersonalizada = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String> hora = const Value.absent(),
                Value<double> latitud = const Value.absent(),
                Value<double> longitud = const Value.absent(),
                Value<String?> direccionReferencia = const Value.absent(),
                Value<int?> cupoVoluntarios = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JornadasLocalCompanion(
                id: id,
                organizadorId: organizadorId,
                titulo: titulo,
                categoria: categoria,
                categoriaPersonalizada: categoriaPersonalizada,
                descripcion: descripcion,
                fecha: fecha,
                hora: hora,
                latitud: latitud,
                longitud: longitud,
                direccionReferencia: direccionReferencia,
                cupoVoluntarios: cupoVoluntarios,
                estado: estado,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizadorId,
                required String titulo,
                required String categoria,
                Value<String?> categoriaPersonalizada = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                required String fecha,
                required String hora,
                required double latitud,
                required double longitud,
                Value<String?> direccionReferencia = const Value.absent(),
                Value<int?> cupoVoluntarios = const Value.absent(),
                Value<String> estado = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JornadasLocalCompanion.insert(
                id: id,
                organizadorId: organizadorId,
                titulo: titulo,
                categoria: categoria,
                categoriaPersonalizada: categoriaPersonalizada,
                descripcion: descripcion,
                fecha: fecha,
                hora: hora,
                latitud: latitud,
                longitud: longitud,
                direccionReferencia: direccionReferencia,
                cupoVoluntarios: cupoVoluntarios,
                estado: estado,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JornadasLocalTable, JornadaLocal>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JornadasLocalTable,
                    JornadaLocal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JornadasLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JornadasLocalTable,
      JornadaLocal,
      $$JornadasLocalTableFilterComposer,
      $$JornadasLocalTableOrderingComposer,
      $$JornadasLocalTableAnnotationComposer,
      $$JornadasLocalTableCreateCompanionBuilder,
      $$JornadasLocalTableUpdateCompanionBuilder,
      (
        JornadaLocal,
        BaseReferences<_$AppDatabase, $JornadasLocalTable, JornadaLocal>,
      ),
      JornadaLocal,
      PrefetchHooks Function()
    >;
typedef $$InscripcionesLocalTableCreateCompanionBuilder =
    InscripcionesLocalCompanion Function({
      Value<String?> id,
      required String jornadaId,
      required String voluntarioId,
      required DateTime createdAt,
      Value<bool> pendingSync,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$InscripcionesLocalTableUpdateCompanionBuilder =
    InscripcionesLocalCompanion Function({
      Value<String?> id,
      Value<String> jornadaId,
      Value<String> voluntarioId,
      Value<DateTime> createdAt,
      Value<bool> pendingSync,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$InscripcionesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $InscripcionesLocalTable> {
  $$InscripcionesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jornadaId => $composableBuilder(
    column: $table.jornadaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voluntarioId => $composableBuilder(
    column: $table.voluntarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InscripcionesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $InscripcionesLocalTable> {
  $$InscripcionesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jornadaId => $composableBuilder(
    column: $table.jornadaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voluntarioId => $composableBuilder(
    column: $table.voluntarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InscripcionesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $InscripcionesLocalTable> {
  $$InscripcionesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jornadaId =>
      $composableBuilder(column: $table.jornadaId, builder: (column) => column);

  GeneratedColumn<String> get voluntarioId => $composableBuilder(
    column: $table.voluntarioId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$InscripcionesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InscripcionesLocalTable,
          InscripcionLocal,
          $$InscripcionesLocalTableFilterComposer,
          $$InscripcionesLocalTableOrderingComposer,
          $$InscripcionesLocalTableAnnotationComposer,
          $$InscripcionesLocalTableCreateCompanionBuilder,
          $$InscripcionesLocalTableUpdateCompanionBuilder,
          (
            InscripcionLocal,
            BaseReferences<
              _$AppDatabase,
              $InscripcionesLocalTable,
              InscripcionLocal
            >,
          ),
          InscripcionLocal,
          PrefetchHooks Function()
        > {
  $$InscripcionesLocalTableTableManager(
    _$AppDatabase db,
    $InscripcionesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InscripcionesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InscripcionesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InscripcionesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String> jornadaId = const Value.absent(),
                Value<String> voluntarioId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesLocalCompanion(
                id: id,
                jornadaId: jornadaId,
                voluntarioId: voluntarioId,
                createdAt: createdAt,
                pendingSync: pendingSync,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                required String jornadaId,
                required String voluntarioId,
                required DateTime createdAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesLocalCompanion.insert(
                id: id,
                jornadaId: jornadaId,
                voluntarioId: voluntarioId,
                createdAt: createdAt,
                pendingSync: pendingSync,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InscripcionesLocalTable, InscripcionLocal>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $InscripcionesLocalTable,
                    InscripcionLocal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InscripcionesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InscripcionesLocalTable,
      InscripcionLocal,
      $$InscripcionesLocalTableFilterComposer,
      $$InscripcionesLocalTableOrderingComposer,
      $$InscripcionesLocalTableAnnotationComposer,
      $$InscripcionesLocalTableCreateCompanionBuilder,
      $$InscripcionesLocalTableUpdateCompanionBuilder,
      (
        InscripcionLocal,
        BaseReferences<
          _$AppDatabase,
          $InscripcionesLocalTable,
          InscripcionLocal
        >,
      ),
      InscripcionLocal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JornadasLocalTableTableManager get jornadasLocal =>
      $$JornadasLocalTableTableManager(_db, _db.jornadasLocal);
  $$InscripcionesLocalTableTableManager get inscripcionesLocal =>
      $$InscripcionesLocalTableTableManager(_db, _db.inscripcionesLocal);
}
