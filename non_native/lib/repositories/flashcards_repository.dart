import 'package:drift/drift.dart';
import '../database/database.dart';
import 'i_flashcards_repository.dart';
import '../models/flashcard.dart';
import '../assets/difficulty.dart';
import '../services/api_service.dart';

class FlashcardsRepository implements IFlashcardsRepository {
  final AppDatabase _db;
  final ApiService _apiService;

  FlashcardsRepository(this._db, this._apiService);

  @override
  Stream<List<Flashcard>> getAllFlashcards(int categoryId) {
    return (_db.select(_db.flashcardsTable)
      ..where((t) => t.categoryId.equals(categoryId) & t.deleted.equals(false)))
        .watch()
        .map((rows) => rows.map((row) => Flashcard(
      localId: row.localId,
      serverId: row.serverId,
      question: row.question,
      answer: row.answer,
      difficulty: row.difficulty,
      categoryId: row.categoryId,
      pendingSync: row.pendingSync,
      deleted: row.deleted,
      lastModified: row.lastModified,
    )).toList());
  }

  @override
  Future<void> syncFromServer(List<dynamic> serverFlashcards) async {
    await _db.transaction(() async {
      for (var data in serverFlashcards) {
        final serverId = data['id'];
        final serverCatId = data['categoryId'];

        final localCat = await (_db.select(_db.categoriesTable)..where((t) => t.serverId.equals(serverCatId))).getSingleOrNull();

        if (localCat != null) {
          final localEntry = await (_db.select(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

          if (localEntry == null) {
            await _db.into(_db.flashcardsTable).insert(FlashcardsTableCompanion(
              serverId: Value(serverId),
              question: Value(data['question']),
              answer: Value(data['answer']),
              difficulty: Value(Difficulty.values[data['difficulty']]),
              categoryId: Value(localCat.localId),
              lastModified: Value(data['lastModified'] ?? 0),
              pendingSync: const Value(false),
              deleted: const Value(false),
            ));
          } else if (!localEntry.pendingSync && (data['lastModified'] ?? 0) > localEntry.lastModified) {

            await (_db.update(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId)))
                .write(FlashcardsTableCompanion(
              question: Value(data['question']),
              answer: Value(data['answer']),
              difficulty: Value(Difficulty.values[data['difficulty']]),
              lastModified: Value(data['lastModified']),
            ));
          }
        }
      }
    });
  }

  Future<void> handleSocketCreate(Map<String, dynamic> data) async {
    final serverId = data['id'];
    final serverCatId = data['categoryId'];

    await _db.transaction(() async {
      final category = await (_db.select(_db.categoriesTable)..where((t) => t.serverId.equals(serverCatId))).getSingleOrNull();

      if (category != null) {
        final exists = await (_db.select(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();
        if (exists == null) {

          await _db.into(_db.flashcardsTable).insert(FlashcardsTableCompanion(
            serverId: Value(serverId),
            question: Value(data['question']),
            answer: Value(data['answer']),
            difficulty: Value(Difficulty.values[data['difficulty']]),
            categoryId: Value(category.localId),
            lastModified: Value(data['lastModified'] ?? 0),
            pendingSync: const Value(false),
            deleted: const Value(false),
          ));

          final newCount = category.flashcardCount + 1;
          await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(category.localId)))
              .write(CategoriesTableCompanion(flashcardCount: Value(newCount)));
        }
      }
    });
  }

  Future<void> handleSocketUpdate(Map<String, dynamic> data) async {
    final serverId = data['id'];
    await (_db.update(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId)))
        .write(FlashcardsTableCompanion(
      question: Value(data['question']),
      answer: Value(data['answer']),
      difficulty: Value(Difficulty.values[data['difficulty']]),
      lastModified: Value(data['lastModified']),
    ));
  }

  Future<void> handleSocketDelete(int serverId) async {
    await _db.transaction(() async {
      final flashcard = await (_db.select(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

      if (flashcard != null) {
        await (_db.delete(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId))).go();

        final category = await (_db.select(_db.categoriesTable)..where((t) => t.localId.equals(flashcard.categoryId))).getSingleOrNull();
        if (category != null && category.flashcardCount > 0) {
          final newCount = category.flashcardCount - 1;
          await (_db.update(_db.categoriesTable)..where((t) => t.localId.equals(category.localId)))
              .write(CategoriesTableCompanion(flashcardCount: Value(newCount)));
        }
      }
    });
  }

  @override
  Future<Flashcard?> getFlashcardById(int id) async {
    final result = await (_db.select(_db.flashcardsTable)..where((t) => t.localId.equals(id))).getSingleOrNull();
    if (result == null) return null;
    return Flashcard(
      localId: result.localId,
      serverId: result.serverId,
      question: result.question,
      answer: result.answer,
      difficulty: result.difficulty,
      categoryId: result.categoryId,
      pendingSync: result.pendingSync,
      deleted: result.deleted,
      lastModified: result.lastModified,
    );
  }

  @override
  Future<Flashcard> addFlashcard(Flashcard flashcard) async {
    final entry = FlashcardsTableCompanion(
      question: Value(flashcard.question),
      answer: Value(flashcard.answer),
      difficulty: Value(flashcard.difficulty),
      categoryId: Value(flashcard.categoryId),
      pendingSync: const Value(true),
      lastModified: Value(DateTime.now().millisecondsSinceEpoch),
    );
    final id = await _db.into(_db.flashcardsTable).insert(entry);
    final localFlashcard = flashcard.copyWith(localId: id, pendingSync: true);

    try {
      final category = await (_db.select(_db.categoriesTable)..where((t) => t.localId.equals(flashcard.categoryId))).getSingle();
      if (category.serverId != null) {
        final serverFlashcard = localFlashcard.copyWith(categoryId: category.serverId!);
        final serverId = await _apiService.createFlashcard(serverFlashcard);

        return await _db.transaction(() async {
          final socketEntry = await (_db.select(_db.flashcardsTable)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

          if (socketEntry != null) {
            await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(id))).go();
            return Flashcard(
                localId: socketEntry.localId,
                serverId: socketEntry.serverId,
                question: socketEntry.question,
                answer: socketEntry.answer,
                difficulty: socketEntry.difficulty,
                categoryId: socketEntry.categoryId,
                pendingSync: socketEntry.pendingSync,
                deleted: socketEntry.deleted,
                lastModified: socketEntry.lastModified
            );
          } else {
            await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(id)))
                .write(FlashcardsTableCompanion(serverId: Value(serverId), pendingSync: const Value(false)));
            return localFlashcard.copyWith(serverId: serverId, pendingSync: false);
          }
        });
      }
    } catch (e) {

      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains("required") ||
          errorMsg.contains("exceeds") ||
          errorMsg.contains("empty") ||
          errorMsg.contains("must be")) {

        await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(id))).go();
        rethrow;
      }
      print("Offline: Flashcard queued.");
    }
    return localFlashcard;
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {

    final oldFlashcard = await getFlashcardById(flashcard.localId);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(flashcard.localId)))
        .write(FlashcardsTableCompanion(
      question: Value(flashcard.question),
      answer: Value(flashcard.answer),
      difficulty: Value(flashcard.difficulty),
      lastModified: Value(timestamp),
      pendingSync: const Value(true),
    ));

    if (flashcard.serverId != null) {
      try {
        await _apiService.updateFlashcard(flashcard.copyWith(lastModified: timestamp));

        await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(flashcard.localId)))
            .write(const FlashcardsTableCompanion(pendingSync: Value(false)));
      } catch (e) {

        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains("required") ||
            errorMsg.contains("exceeds") ||
            errorMsg.contains("empty") ||
            errorMsg.contains("must be")) {

          if (oldFlashcard != null) {
            await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(flashcard.localId)))
                .write(FlashcardsTableCompanion(
              question: Value(oldFlashcard.question),
              answer: Value(oldFlashcard.answer),
              difficulty: Value(oldFlashcard.difficulty),
              lastModified: Value(oldFlashcard.lastModified),
              pendingSync: Value(oldFlashcard.pendingSync!),
            ));
          }
          rethrow;
        }
        print("Offline: Flashcard update queued.");
      }
    }
  }

  @override
  Future<void> deleteFlashcard(int id) async {
    final flashcard = await getFlashcardById(id);
    if (flashcard == null) return;

    await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(id)))
        .write(const FlashcardsTableCompanion(deleted: Value(true), pendingSync: Value(true)));

    if (flashcard.serverId != null) {
      try {
        await _apiService.deleteFlashcard(flashcard.serverId!);
        await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(id))).go();
      } catch (e) {
        print("Offline: Flashcard delete queued.");
      }
    } else {
      await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(id))).go();
    }
  }

  @override
  Future<void> syncPending() async {
    final pending = await (_db.select(_db.flashcardsTable)..where((t) => t.pendingSync.equals(true))).get();

    for (var row in pending) {
      if (row.deleted) {
        if (row.serverId != null) {
          try {
            await _apiService.deleteFlashcard(row.serverId!);
            await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(row.localId))).go();
          } catch (_) {}
        } else {
          await (_db.delete(_db.flashcardsTable)..where((t) => t.localId.equals(row.localId))).go();
        }
      } else if (row.serverId == null) {
        try {
          final cat = await (_db.select(_db.categoriesTable)..where((t) => t.localId.equals(row.categoryId))).getSingleOrNull();
          if (cat != null && cat.serverId != null) {
            final newId = await _apiService.createFlashcard(Flashcard(
                localId: row.localId, question: row.question, answer: row.answer,
                difficulty: row.difficulty, categoryId: cat.serverId!,
                lastModified: row.lastModified
            ));
            await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(row.localId)))
                .write(FlashcardsTableCompanion(serverId: Value(newId), pendingSync: const Value(false)));
          }
        } catch (_) {}
      } else {
        try {
          await _apiService.updateFlashcard(Flashcard(
              localId: row.localId, serverId: row.serverId, question: row.question, answer: row.answer,
              difficulty: row.difficulty, categoryId: row.categoryId, lastModified: row.lastModified
          ));
          await (_db.update(_db.flashcardsTable)..where((t) => t.localId.equals(row.localId)))
              .write(const FlashcardsTableCompanion(pendingSync: Value(false)));
        } catch (_) {}
      }
    }
  }
}