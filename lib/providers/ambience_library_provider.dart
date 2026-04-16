import 'package:flutter/foundation.dart';

import '../core/ambience_repository.dart';
import '../models/ambience.dart';

class AmbienceLibraryProvider extends ChangeNotifier {
  AmbienceLibraryProvider({
    required AmbienceRepository repository,
  }) : _repository = repository;

  final AmbienceRepository _repository;

  List<Ambience> _all = const [];
  bool _isLoading = false;
  String? _error;
  String _query = '';
  String? _selectedTag;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  String? get selectedTag => _selectedTag;
  List<Ambience> get allAmbiences => _all;

  List<Ambience> get filteredAmbiences {
    final q = _query.trim().toLowerCase();

    return _all.where((a) {
      final matchesTag =
          _selectedTag == null || a.tag.toLowerCase() == _selectedTag!.toLowerCase();
      if (!matchesTag) return false;

      if (q.isEmpty) return true;
      return a.title.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _repository.loadAmbiences();
    } catch (e) {
      _error = e.toString();
      _all = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void filterByTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _selectedTag = null;
    notifyListeners();
  }
}
