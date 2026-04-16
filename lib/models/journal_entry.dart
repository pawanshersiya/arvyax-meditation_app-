class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAtEpochMillis,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.mood,
    required this.reflectionText,
  });

  final String id;
  final int createdAtEpochMillis;
  final String ambienceId;
  final String ambienceTitle;
  final String mood;
  final String reflectionText;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final v = json[key];
      if (v is String) return v;
      return '';
    }

    int readInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return 0;
    }

    return JournalEntry(
      id: readString('id'),
      createdAtEpochMillis: readInt('createdAtEpochMillis'),
      ambienceId: readString('ambienceId'),
      ambienceTitle: readString('ambienceTitle'),
      mood: readString('mood'),
      reflectionText: readString('reflectionText'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'createdAtEpochMillis': createdAtEpochMillis,
        'ambienceId': ambienceId,
        'ambienceTitle': ambienceTitle,
        'mood': mood,
        'reflectionText': reflectionText,
      };
}
