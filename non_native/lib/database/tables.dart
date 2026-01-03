import 'package:drift/drift.dart';
import '../assets/difficulty.dart';

class Difficulties extends TypeConverter<Difficulty, int> {
  const Difficulties();
  @override
  Difficulty fromSql(int fromDb) => Difficulty.values[fromDb];
  @override
  int toSql(Difficulty value) => value.index;
}

class CategoriesTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 30)();

  IntColumn get flashcardCount => integer().withDefault(const Constant(0))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  IntColumn get lastModified => integer().withDefault(const Constant(0))();
}

class FlashcardsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();

  TextColumn get question => text().withLength(min: 1, max: 150)();
  TextColumn get answer => text().withLength(min: 1, max: 150)();

  IntColumn get difficulty => integer().map(const Difficulties())();

  IntColumn get categoryId => integer().references(CategoriesTable, #localId, onDelete: KeyAction.cascade)();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get lastModified => integer().withDefault(const Constant(0))();
}