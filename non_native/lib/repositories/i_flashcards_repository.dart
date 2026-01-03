import '../models/flashcard.dart';

abstract class IFlashcardsRepository {
  Stream<List<Flashcard>> getAllFlashcards(int categoryId);

  Future<Flashcard?> getFlashcardById(int id);
  Future<Flashcard> addFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(int id);
  Future<void> updateFlashcard(Flashcard flashcard);
}