import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

class CachedTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get description => text().nullable()();
  TextColumn get occurredAt => text()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  RealColumn get score => real()();
  TextColumn get status => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedSimulations extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  RealColumn get recommendedAmount => real()();
  TextColumn get currency => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get toolCallsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    CachedTransactions,
    CachedSnapshots,
    CachedSimulations,
    CachedChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() {
    return AppDatabase(_openConnection());
  }

  @override
  int get schemaVersion => 1;

  Future<List<CachedTransaction>> transactionsForBusiness(String businessId) {
    return (select(cachedTransactions)
          ..where((t) => t.businessId.equals(businessId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<void> replaceTransactions(
    String businessId,
    List<CachedTransactionsCompanion> rows,
  ) async {
    await transaction(() async {
      await (delete(
        cachedTransactions,
      )..where((t) => t.businessId.equals(businessId))).go();
      await batch((b) => b.insertAll(cachedTransactions, rows));
    });
  }

  Future<void> upsertSnapshot(CachedSnapshotsCompanion row) =>
      into(cachedSnapshots).insertOnConflictUpdate(row);

  Future<CachedSnapshot?> latestSnapshot(String businessId) {
    return (select(cachedSnapshots)
          ..where((s) => s.businessId.equals(businessId))
          ..orderBy([
            (s) => OrderingTerm(
              expression: s.generatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertSimulation(CachedSimulationsCompanion row) =>
      into(cachedSimulations).insertOnConflictUpdate(row);

  Future<List<CachedSimulation>> simulationsFor(String businessId) {
    return (select(cachedSimulations)
          ..where((s) => s.businessId.equals(businessId))
          ..orderBy([
            (s) => OrderingTerm(
              expression: s.generatedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<void> insertChatMessage(CachedChatMessagesCompanion row) =>
      into(cachedChatMessages).insert(row);

  Future<List<CachedChatMessage>> chatFor(String businessId) {
    return (select(cachedChatMessages)
          ..where((m) => m.businessId.equals(businessId))
          ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  Future<void> clearChat(String businessId) => (delete(
    cachedChatMessages,
  )..where((m) => m.businessId.equals(businessId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finora_twin.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override in main()'),
);
