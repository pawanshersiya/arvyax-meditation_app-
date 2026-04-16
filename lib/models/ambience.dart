class Ambience {
  final String id;
  final String title;
  final String tag;
  final int durationSeconds;
  final String imageAsset;
  final String audioAsset;
  final String description;
  final List<String> sensory;

  const Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationSeconds,
    required this.imageAsset,
    required this.audioAsset,
    required this.description,
    required this.sensory,
  });

  factory Ambience.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {required String fieldName}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      throw FormatException('Invalid "$fieldName" value: $value');
    }

    final sensoryRaw = json['sensory'];
    final sensory = <String>[
      ...((sensoryRaw is List) ? sensoryRaw.whereType<String>() : <String>[])
    ];

    return Ambience(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      tag: (json['tag'] as String?) ?? '',
      durationSeconds: parseInt(
        json['durationSeconds'],
        fieldName: 'durationSeconds',
      ),
      imageAsset: (json['imageAsset'] as String?) ?? '',
      audioAsset: (json['audioAsset'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      sensory: sensory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tag': tag,
      'durationSeconds': durationSeconds,
      'imageAsset': imageAsset,
      'audioAsset': audioAsset,
      'description': description,
      'sensory': sensory,
    };
  }
}
