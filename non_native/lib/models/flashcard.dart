import '../assets/difficulty.dart';

class Flashcard {
  final int localId;
  final int? serverId;
  final String question;
  final String answer;
  final Difficulty difficulty;
  final int categoryId;
  final bool? pendingSync;
  final bool? deleted;
  final int lastModified;

  Flashcard({
    required this.localId,
    this.serverId,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.categoryId,
    this.pendingSync = false,
    this.deleted = false,
    int? lastModified,
  }) : lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch;

  Flashcard copyWith({
    int? localId,
    int? serverId,
    String? question,
    String? answer,
    Difficulty? difficulty,
    int? categoryId,
    bool? pendingSync,
    bool? deleted,
    int? lastModified,
  }) {
    return Flashcard(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      difficulty: difficulty ?? this.difficulty,
      categoryId: categoryId ?? this.categoryId,
      pendingSync: pendingSync ?? this.pendingSync,
      deleted: deleted ?? this.deleted,
      lastModified: lastModified ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}