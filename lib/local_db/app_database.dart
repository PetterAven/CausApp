import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/jornada.dart';

part 'app_database.g.dart';

@DataClassName('JornadaLocal')
class JornadasLocal extends Table {
  TextColumn get id => text()();
  TextColumn get organizadorId => text()();
  TextColumn get titulo => text()();
  TextColumn get categoria => text()();
  TextColumn get categoriaPersonalizada => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get fecha => text()();
  TextColumn get hora => text()();
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();
  TextColumn get direccionReferencia => text().nullable()();
  IntColumn get cupoVoluntarios => integer().nullable()();
  TextColumn get estado => text().withDefault(const Constant('activa'))();
  TextColumn get estadoProgreso => text().withDefault(const Constant('pendiente'))();
  BoolColumn get aceptaDonacionesDinero => boolean().withDefault(const Constant(false))();
  BoolColumn get aceptaDonacionesArticulos => boolean().withDefault(const Constant(false))();
  RealColumn get metaDonacionDinero => real().nullable()();
  TextColumn get articulosSolicitados => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InscripcionLocal')
class InscripcionesLocal extends Table {
  TextColumn get id => text().nullable()();
  TextColumn get jornadaId => text()();
  TextColumn get voluntarioId => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {jornadaId, voluntarioId};
}

@DriftDatabase(tables: [JornadasLocal, InscripcionesLocal])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
              "UPDATE jornadas_local SET estado_progreso = 'pendiente' WHERE estado_progreso IS NULL;",
            );
          }
          if (from < 3) {
            await customStatement("ALTER TABLE jornadas_local ADD COLUMN acepta_donaciones_dinero INTEGER NOT NULL DEFAULT 0;");
            await customStatement("ALTER TABLE jornadas_local ADD COLUMN acepta_donaciones_articulos INTEGER NOT NULL DEFAULT 0;");
            await customStatement("ALTER TABLE jornadas_local ADD COLUMN meta_donacion_dinero REAL;");
            await customStatement("ALTER TABLE jornadas_local ADD COLUMN articulos_solicitados TEXT;");
          }
        },
      );

  // --- MÉTODOS PARA JORNADAS ---

  Stream<List<JornadaLocal>> watchJornadas() {
    return (select(jornadasLocal)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<List<JornadaLocal>> obtenerJornadasLocal() async {
    return (select(jornadasLocal)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<void> upsertJornada(Jornada jornada, {DateTime? syncedAt}) async {
    into(jornadasLocal).insertOnConflictUpdate(
      JornadasLocalCompanion.insert(
        id: jornada.id,
        organizadorId: jornada.organizadorId,
        titulo: jornada.titulo,
        categoria: jornada.categoria,
        categoriaPersonalizada: Value(jornada.categoriaPersonalizada),
        descripcion: Value(jornada.descripcion),
        fecha: jornada.fecha,
        hora: jornada.hora,
        latitud: jornada.latitud,
        longitud: jornada.longitud,
        direccionReferencia: Value(jornada.direccionReferencia),
        cupoVoluntarios: Value(jornada.cupoVoluntarios),
        estado: Value(jornada.estado),
        estadoProgreso: Value(jornada.estadoProgreso),
        aceptaDonacionesDinero: Value(jornada.aceptaDonacionesDinero),
        aceptaDonacionesArticulos: Value(jornada.aceptaDonacionesArticulos),
        metaDonacionDinero: Value(jornada.metaDonacionDinero),
        articulosSolicitados: Value(jsonEncode(jornada.articulosSolicitados)),
        createdAt: jornada.createdAt,
        syncedAt: Value(syncedAt ?? DateTime.now()),
      ),
    );
  }

  Future<void> upsertJornadas(List<Jornada> jornadas) async {
    await batch((batch) {
      for (var jornada in jornadas) {
        batch.insert(
          jornadasLocal,
          JornadasLocalCompanion.insert(
            id: jornada.id,
            organizadorId: jornada.organizadorId,
            titulo: jornada.titulo,
            categoria: jornada.categoria,
            categoriaPersonalizada: Value(jornada.categoriaPersonalizada),
            descripcion: Value(jornada.descripcion),
            fecha: jornada.fecha,
            hora: jornada.hora,
            latitud: jornada.latitud,
            longitud: jornada.longitud,
            direccionReferencia: Value(jornada.direccionReferencia),
            cupoVoluntarios: Value(jornada.cupoVoluntarios),
            estado: Value(jornada.estado),
            estadoProgreso: Value(jornada.estadoProgreso),
            aceptaDonacionesDinero: Value(jornada.aceptaDonacionesDinero),
            aceptaDonacionesArticulos: Value(jornada.aceptaDonacionesArticulos),
            metaDonacionDinero: Value(jornada.metaDonacionDinero),
            articulosSolicitados: Value(jsonEncode(jornada.articulosSolicitados)),
            createdAt: jornada.createdAt,
            syncedAt: Value(DateTime.now()),
          ),
          onConflict: DoUpdate((old) => JornadasLocalCompanion.insert(
                id: jornada.id,
                organizadorId: jornada.organizadorId,
                titulo: jornada.titulo,
                categoria: jornada.categoria,
                categoriaPersonalizada: Value(jornada.categoriaPersonalizada),
                descripcion: Value(jornada.descripcion),
                fecha: jornada.fecha,
                hora: jornada.hora,
                latitud: jornada.latitud,
                longitud: jornada.longitud,
                direccionReferencia: Value(jornada.direccionReferencia),
                cupoVoluntarios: Value(jornada.cupoVoluntarios),
                estado: Value(jornada.estado),
                estadoProgreso: Value(jornada.estadoProgreso),
                aceptaDonacionesDinero: Value(jornada.aceptaDonacionesDinero),
                aceptaDonacionesArticulos: Value(jornada.aceptaDonacionesArticulos),
                metaDonacionDinero: Value(jornada.metaDonacionDinero),
                articulosSolicitados: Value(jsonEncode(jornada.articulosSolicitados)),
                createdAt: jornada.createdAt,
                syncedAt: Value(DateTime.now()),
              )),
        );
      }
    });
  }

  // --- MÉTODOS PARA INSCRIPCIONES ---

  Stream<List<InscripcionLocal>> watchInscripcionesUsuario(String voluntarioId) {
    return (select(inscripcionesLocal)
          ..where((t) => t.voluntarioId.equals(voluntarioId) & t.isDeleted.equals(false)))
        .watch();
  }

  Future<List<InscripcionLocal>> obtenerInscripcionesLocal(String voluntarioId) async {
    return (select(inscripcionesLocal)
          ..where((t) => t.voluntarioId.equals(voluntarioId) & t.isDeleted.equals(false)))
        .get();
  }

  Future<void> guardarInscripcionLocal({
    String? id,
    required String jornadaId,
    required String voluntarioId,
    required DateTime createdAt,
    bool pendingSync = true,
    bool isDeleted = false,
  }) async {
    await into(inscripcionesLocal).insertOnConflictUpdate(
      InscripcionesLocalCompanion.insert(
        id: Value(id),
        jornadaId: jornadaId,
        voluntarioId: voluntarioId,
        createdAt: createdAt,
        pendingSync: Value(pendingSync),
        isDeleted: Value(isDeleted),
      ),
    );
  }

  Future<void> eliminarInscripcionLocal(String jornadaId, String voluntarioId) async {
    // Si estaba pendiente de sincronizar y nunca llegó al servidor, podemos borrarla o marcar isDeleted.
    // Si ya estaba sincronizada (pendingSync = false), la marcamos como isDeleted = true y pendingSync = true para borrarla en Supabase al sincronizar.
    final existing = await (select(inscripcionesLocal)
          ..where((t) => t.jornadaId.equals(jornadaId) & t.voluntarioId.equals(voluntarioId)))
        .getSingleOrNull();

    if (existing != null) {
      if (existing.pendingSync && (existing.id == null || existing.id!.isEmpty)) {
        // Nunca se sincronizó, se puede eliminar directamente
        await (delete(inscripcionesLocal)
              ..where((t) => t.jornadaId.equals(jornadaId) & t.voluntarioId.equals(voluntarioId)))
            .go();
      } else {
        // Ya existía en servidor, marcar para borrado pendiente
        await (update(inscripcionesLocal)
              ..where((t) => t.jornadaId.equals(jornadaId) & t.voluntarioId.equals(voluntarioId)))
            .write(const InscripcionesLocalCompanion(
              isDeleted: Value(true),
              pendingSync: Value(true),
            ));
      }
    }
  }

  Future<List<InscripcionLocal>> obtenerPendientesSync() async {
    return (select(inscripcionesLocal)..where((t) => t.pendingSync.equals(true))).get();
  }

  Future<void> marcarSincronizado(String jornadaId, String voluntarioId, {String? serverId}) async {
    await (update(inscripcionesLocal)
          ..where((t) => t.jornadaId.equals(jornadaId) & t.voluntarioId.equals(voluntarioId)))
        .write(InscripcionesLocalCompanion(
      id: serverId != null ? Value(serverId) : const Value.absent(),
      pendingSync: const Value(false),
    ));
  }

  Future<void> eliminarInscripcionDefinitiva(String jornadaId, String voluntarioId) async {
    await (delete(inscripcionesLocal)
          ..where((t) => t.jornadaId.equals(jornadaId) & t.voluntarioId.equals(voluntarioId)))
        .go();
  }

  Stream<int> watchPendientesCount() {
    return (select(inscripcionesLocal)..where((t) => t.pendingSync.equals(true)))
        .watch()
        .map((rows) => rows.length);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'causapp_local.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
