import 'package:flutter/foundation.dart';

import '../core/journal_repository.dart';
import '../models/ambience.dart';
import '../models/journal_entry.dart';

enum JournalMood {
  calm('Calm'),
  grounded('Grounded'),
  energized('Energized'),
  sleepy('Sleepy');

  const JournalMood(this.label);
  final String label;

  static JournalMood? fromLabel(String label) {
    for (final m in values) {
      if (m.label == label) return m;
    }
    return null;
  }
}

class JournalProvider extends ChangeNotifier {
  JournalProvider({
    required JournalRepository repository,
  }) : _repository = repository;

  final JournalRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<JournalEntry> _entries = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<JournalEntry> get entries => _entries;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _repository.loadEntries();
    } catch (e) {
      _error = e.toString();
      _entries = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReflection({
    required Ambience ambience,
    required JournalMood mood,
    required String reflectionText,
  }) async {
    final entry = JournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAtEpochMillis: DateTime.now().millisecondsSinceEpoch,
      ambienceId: ambience.id,
      ambienceTitle: ambience.title,
      mood: mood.label,
      reflectionText: reflectionText.trim(),
    );

    await _repository.addEntry(entry);
    await load();
  }
}
