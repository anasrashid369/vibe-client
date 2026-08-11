class TasteProfileEntity {
  const TasteProfileEntity({
    required this.summaryText,
    required this.topGenres,
    required this.topPeople,
    required this.moodTags,
    required this.interactionCountAtUpdate,
    required this.updatedAt,
  });

  final String summaryText;
  final List<String> topGenres;
  final List<String> topPeople;
  final List<String> moodTags;
  final int interactionCountAtUpdate;
  final DateTime updatedAt;

  factory TasteProfileEntity.empty() => TasteProfileEntity(
        summaryText: 'No preferences recorded yet.',
        topGenres: const [],
        topPeople: const [],
        moodTags: const [],
        interactionCountAtUpdate: 0,
        updatedAt: DateTime.now(),
      );
}