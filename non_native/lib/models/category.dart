class Category {
  final int localId;
  final int? serverId;
  final String name;
  final int flashcardCount;
  final bool? deleted;
  final bool? pendingSync;
  final int lastModified;

  Category({
    required this.localId,
    this.serverId,
    required this.name,
    required this.flashcardCount,
    this.deleted = false,
    this.pendingSync = false,
    int? lastModified,
  }) : lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch;

  Category copyWith({
    int? localId,
    int? serverId,
    String? name,
    int? flashcardCount,
    bool? deleted,
    bool? pendingSync,
    int? lastModified,
  }) {
    return Category(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      deleted: deleted ?? this.deleted,
      pendingSync: pendingSync ?? this.pendingSync,
      lastModified: lastModified ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}