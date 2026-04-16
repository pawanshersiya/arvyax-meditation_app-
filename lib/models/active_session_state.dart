import 'dart:convert';

import 'ambience.dart';

class ActiveSessionState {
  const ActiveSessionState({
    required this.ambience,
    required this.elapsedSeconds,
    required this.isPlaying,
    required this.lastUpdatedEpochMillis,
  });

  final Ambience ambience;
  final int elapsedSeconds;
  final bool isPlaying;
  final int lastUpdatedEpochMillis;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ambience': ambience.toJson(),
        'elapsedSeconds': elapsedSeconds,
        'isPlaying': isPlaying,
        'lastUpdatedEpochMillis': lastUpdatedEpochMillis,
      };

  factory ActiveSessionState.fromJson(Map<String, dynamic> json) {
    final ambienceJson = json['ambience'];
    if (ambienceJson is! Map) {
      throw const FormatException('Missing "ambience" object.');
    }

    return ActiveSessionState(
      ambience: Ambience.fromJson(ambienceJson.cast<String, dynamic>()),
      elapsedSeconds: (json['elapsedSeconds'] as num).toInt(),
      isPlaying: (json['isPlaying'] as bool?) ?? false,
      lastUpdatedEpochMillis: (json['lastUpdatedEpochMillis'] as num).toInt(),
    );
  }

  static String encode(ActiveSessionState state) => jsonEncode(state.toJson());

  static ActiveSessionState decode(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw const FormatException('Active session JSON must be an object');
    }
    return ActiveSessionState.fromJson(decoded.cast<String, dynamic>());
  }
}
