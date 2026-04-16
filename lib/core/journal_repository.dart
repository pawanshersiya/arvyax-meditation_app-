import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> loadEntries();
  Future<void> addEntry(JournalEntry entry);
}

class HiveJournalRepository implements JournalRepository {
  HiveJournalRepository({
    this.boxName = 'arvyax_journal',
    this.entriesKey = 'journalEntries',
  });

  final String boxName;
  final String entriesKey;

  Future<Box<String>> _box() async {
    return Hive.openBox<String>(boxName);
  }

  @override
  Future<List<JournalEntry>> loadEntries() async {
    final box = await _box();
    final stored = box.get(entriesKey);
    if (stored == null || stored.isEmpty) return const [];

    final decoded = jsonDecode(stored);
    if (decoded is! List) return const [];

    return decoded
        .map((e) => JournalEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    final box = await _box();
    final stored = box.get(entriesKey);

    final decodedList = <JournalEntry>[];
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored);
      if (decoded is List) {
        decodedList.addAll(
          decoded
              .map((e) => JournalEntry.fromJson((e as Map).cast<String, dynamic>()))
              .toList(growable: false),
        );
      }
    }

    decodedList.insert(0, entry);
    final toStore = decodedList.map((e) => e.toJson()).toList(growable: false);
    await box.put(entriesKey, jsonEncode(toStore));
  }
}
