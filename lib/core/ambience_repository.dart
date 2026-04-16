import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/ambience.dart';

abstract class AmbienceRepository {
  Future<List<Ambience>> loadAmbiences();
}

class AssetAmbienceRepository implements AmbienceRepository {
  AssetAmbienceRepository({
    this.assetPath = 'assets/data/ambiences.json',
  });

  final String assetPath;

  @override
  Future<List<Ambience>> loadAmbiences() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Ambience JSON must be a list');
    }

    return decoded
        .map((e) => Ambience.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }
}
