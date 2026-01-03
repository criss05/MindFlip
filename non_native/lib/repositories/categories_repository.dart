import 'package:drift/drift.dart';
import '../database/database.dart';
import 'i_categories_repository.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoriesRepository implements ICategoriesRepository {
  final AppDatabase _db;
  final ApiService _apiService;

  CategoriesRepository(this._db, this._apiService);

  @override
  Stream<List<Category>> getAllCategories() {
    return (_db.select(_db.categoriesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.name)])
      ..where((t) => t.deleted.equals(false)))
        .watch()
        .map((rows) => rows.map((row) => Category(
      localId: row.localId,
      serverId: row.serverId,
      name: row.name,
      flashcardCount: row.flashcardCount,
      deleted: row.deleted,
      pendingSync: row.pendingSync,
      lastModified: row.lastModified,
    )).toList());
  }

  Future<void> syncFromServer(List<dynamic> serverCategories) async {
    await _db.transaction(() async {
      for (var data in serverCategories) {
        final serverId = data['id'];
        final localEntry = await (_db.select(_db.categoriesTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

        if (localEntry == null) {
          await _db.into(_db.categoriesTable).insert(CategoriesTableCompanion(
            serverId: Value(serverId),
            name: Value(data['name']),
            flashcardCount: Value(data['flashcardCount'] ?? 0),
            lastModified: Value(data['lastModified'] ?? 0),
            pendingSync: const Value(false),
            deleted: const Value(false),
          ));
        } else if (!localEntry.pendingSync) {
          await (_db.update(_db.categoriesTable)..where((t) => t.serverId.equals(serverId)))
              .write(CategoriesTableCompanion(
            name: Value(data['name']),
            flashcardCount: Value(data['flashcardCount'] ?? 0),
            lastModified: Value(data['lastModified']),
          ));
        }
      }
    });
  }

  Future<void> handleSocketCreate(Map<String, dynamic> data) async {
    final serverId = data['id'];
    await _db.transaction(() async {
      final exists = await (_db.select(_db.categoriesTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();
      if (exists == null) {
        await _db.into(_db.categoriesTable).insert(CategoriesTableCompanion(
          serverId: Value(serverId),
          name: Value(data['name']),
          flashcardCount: Value(data['flashcardCount'] ?? 0),
          lastModified: Value(data['lastModified'] ?? 0),
          pendingSync: const Value(false),
          deleted: const Value(false),
        ));
      }
    });
  }

  Future<void> handleSocketUpdate(Map<String, dynamic> data) async {
    final serverId = data['id'];
    await (_db.update(_db.categoriesTable)..where((t) => t.serverId.equals(serverId)))
        .write(CategoriesTableCompanion(
      name: Value(data['name']),
      lastModified: Value(data['lastModified']),
    ));
  }

  Future<void> handleSocketDelete(int serverId) async {
    await (_db.delete(_db.categoriesTable)..where((t) => t.serverId.equals(serverId))).go();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final result = await (_db.select(_db.categoriesTable)..where((t) => t.localId.equals(id))).getSingleOrNull();
    if (result == null) return null;
    return Category(
      localId: result.localId,
      name: result.name,
      flashcardCount: result.flashcardCount,
      serverId: result.serverId,
      deleted: result.deleted,
      pendingSync: result.pendingSync,
      lastModified: result.lastModified,
    );
  }

  @override
  Future<Category> addCategory(Category category) async {
    final entry = CategoriesTableCompanion(
      name: Value(category.name),
      flashcardCount: const Value(0),
      pendingSync: const Value(true),
      lastModified: Value(DateTime.now().millisecondsSinceEpoch),
    );
    final localId = await _db.into(_db.categoriesTable).insert(entry);
    final localCategory = category.copyWith(localId: localId, pendingSync: true);

    try {
      final serverId = await _apiService.createCategory(localCategory);

      return await _db.transaction(() async {
        final socketEntry = await (_db.select(_db.categoriesTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

        if (socketEntry != null) {

          await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(localId))).go();

          return Category(
              localId: socketEntry.localId,
              serverId: socketEntry.serverId,
              name: socketEntry.name,
              flashcardCount: socketEntry.flashcardCount,
              deleted: socketEntry.deleted,
              pendingSync: socketEntry.pendingSync,
              lastModified: socketEntry.lastModified
          );
        } else {

          await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(localId)))
              .write(CategoriesTableCompanion(
            serverId: Value(serverId),
            pendingSync: const Value(false),
          ));
          return localCategory.copyWith(serverId: serverId, pendingSync: false);
        }
      });

    } catch (e) {

      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains("required") ||
          errorMsg.contains("exceeds") ||
          errorMsg.contains("empty") ||
          errorMsg.contains("must be")) {

        await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(localId))).go();
        rethrow;
      }

      print("Offline: Category stored locally.");
      return localCategory;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {

    final oldCategory = await getCategoryById(category.localId);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(category.localId)))
        .write(CategoriesTableCompanion(
      name: Value(category.name),
      lastModified: Value(timestamp),
      pendingSync: const Value(true),
    ));

    if (category.serverId != null) {
      try {
        await _apiService.updateCategory(category.copyWith(lastModified: timestamp));


        await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(category.localId)))
            .write(const CategoriesTableCompanion(pendingSync: Value(false)));
      } catch (e) {

        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains("required") ||
            errorMsg.contains("exceeds") ||
            errorMsg.contains("empty") ||
            errorMsg.contains("must be")) {

          if (oldCategory != null) {
            await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(category.localId)))
                .write(CategoriesTableCompanion(
              name: Value(oldCategory.name),
              lastModified: Value(oldCategory.lastModified),
              pendingSync: Value(oldCategory.pendingSync!),
            ));
          }
          rethrow;
        }
        print("Offline: Update queued.");
      }
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    final category = await getCategoryById(id);
    if (category == null) return;

    await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(id)))
        .write(const CategoriesTableCompanion(deleted: Value(true), pendingSync: Value(true)));

    if (category.serverId != null) {
      try {
        await _apiService.deleteCategory(category.serverId!);
        await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(id))).go();
      } catch (e) {
        print("Offline: Delete queued.");
      }
    } else {
      await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(id))).go();
    }
  }

  @override
  Future<void> incFlashcardCount(int categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category != null) {
      final count = category.flashcardCount + 1;
      await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(categoryId)))
          .write(CategoriesTableCompanion(flashcardCount: Value(count)));
    }
  }

  @override
  Future<void> decFlashcardCount(int categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category != null && category.flashcardCount > 0) {
      final count = category.flashcardCount - 1;
      await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(categoryId)))
          .write(CategoriesTableCompanion(flashcardCount: Value(count)));
    }
  }

  @override
  Future<void> syncPending() async {
    final pending = await (_db.select(_db.categoriesTable)
      ..where((t) => t.pendingSync.equals(true)))
        .get();

    for (var row in pending) {

      if (row.deleted) {
        if (row.serverId != null) {
          try {
            await _apiService.deleteCategory(row.serverId!);
            await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(row.localId))).go();
          } catch (_) {}
        } else {
          await (_db.delete(_db.categoriesTable)..where((t) => t.localId.equals(row.localId))).go();
        }
      } else if (row.serverId == null) {
        try {
          final newId = await _apiService.createCategory(Category(
              localId: row.localId,
              name: row.name,
              flashcardCount: 0,
              lastModified: row.lastModified
          ));
          await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(row.localId)))
              .write(CategoriesTableCompanion(serverId: Value(newId), pendingSync: const Value(false)));
        } catch (_) {}
      } else {
        try {
          await _apiService.updateCategory(Category(
              localId: row.localId,
              serverId: row.serverId,
              name: row.name,
              flashcardCount: row.flashcardCount,
              lastModified: row.lastModified
          ));
          await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(row.localId)))
              .write(const CategoriesTableCompanion(pendingSync: Value(false)));
        } catch (_) {}
      }
    }
  }
}