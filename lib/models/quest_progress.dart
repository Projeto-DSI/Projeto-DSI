class QuestProgress {
  final String uid;
  final List<String> completedIds;
  final DateTime? lastUpdated;

  const QuestProgress({
    required this.uid,
    required this.completedIds,
    this.lastUpdated,
  });

  factory QuestProgress.empty(String uid) => QuestProgress(
        uid: uid,
        completedIds: const [],
      );

  factory QuestProgress.fromMap(String uid, Map<String, dynamic> map) {
    return QuestProgress(
      uid: uid,
      completedIds: List<String>.from(map['completed'] ?? []),
      lastUpdated: map['last_updated'] != null
          ? (map['last_updated'] as dynamic).toDate()
          : null,
    );
  }

  bool isCompleted(String questId) => completedIds.contains(questId);

  int get totalCompleted => completedIds.length;

  QuestProgress withCompleted(String questId) {
    if (completedIds.contains(questId)) return this;
    return QuestProgress(
      uid: uid,
      completedIds: [...completedIds, questId],
      lastUpdated: DateTime.now(),
    );
  }
}
