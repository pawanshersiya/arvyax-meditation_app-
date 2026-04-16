import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../models/active_session_state.dart';
import '../models/ambience.dart';

enum SessionEndReason { completed, manual }

class SessionPlayerProvider extends ChangeNotifier {
  SessionPlayerProvider() {
    _restoreIfAny();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _ticker;

  Ambience? _ambience;
  bool _isPlaying = false;
  bool _hasActiveSession = false;
  int _elapsedSeconds = 0;
  int _audioDurationSeconds = 0;
  String? _audioError;
  int _endEventId = 0;

  static const String _boxName = 'arvyax';
  static const String _activeKey = 'activeSession';
  bool _isHiveReady = false;

  bool get hasActiveSession => _hasActiveSession;
  Ambience? get ambience => _ambience;
  bool get isPlaying => _isPlaying;
  int get elapsedSeconds => _elapsedSeconds;
  int get sessionDurationSeconds => _ambience?.durationSeconds ?? 0;
  String? get audioError => _audioError;
  int get endEventId => _endEventId;
  int get audioDurationSeconds => _audioDurationSeconds;

  Future<void> _ensureHiveReady() async {
    if (_isHiveReady) return;
    await Hive.openBox<String>(_boxName);
    _isHiveReady = true;
  }

  Future<Box<String>> _box() async {
    await _ensureHiveReady();
    return Hive.box<String>(_boxName);
  }

  Future<void> _persistState(ActiveSessionState state) async {
    try {
      final box = await _box();
      await box.put(_activeKey, ActiveSessionState.encode(state));
    } catch (_) {}
  }

  Future<void> _clearPersistedState() async {
    try {
      final box = await _box();
      await box.delete(_activeKey);
    } catch (_) {}
  }

  Future<void> _restoreIfAny() async {
    if (_hasActiveSession) return;

    try {
      await _ensureHiveReady();
      final box = Hive.box<String>(_boxName);
      final stored = box.get(_activeKey);
      if (stored == null || stored.isEmpty) return;

      final restored = ActiveSessionState.decode(stored);
      final now = DateTime.now().millisecondsSinceEpoch;
      int elapsed = restored.elapsedSeconds;

      if (restored.isPlaying) {
        final deltaSeconds =
            ((now - restored.lastUpdatedEpochMillis) / 1000).floor();
        elapsed += deltaSeconds;
      }

      if (elapsed >= restored.ambience.durationSeconds) {
        await endSession(reason: SessionEndReason.completed);
        return;
      }

      _setSession(restored.ambience, elapsed: elapsed, isPlaying: false);
      await _loadAudioAndSeek(
        restored.ambience.audioAsset,
        targetElapsedSeconds: elapsed,
      );

      if (restored.isPlaying) {
        await play();
      }
      notifyListeners();
    } catch (_) {
      await _clearPersistedState();
    }
  }

  void _setSession(
    Ambience ambience, {
    required int elapsed,
    required bool isPlaying,
  }) {
    _ambience = ambience;
    _elapsedSeconds = elapsed;
    _isPlaying = isPlaying;
    _hasActiveSession = true;
    _audioError = null;
    _audioDurationSeconds = 0;
    notifyListeners();
  }

  Future<void> startSession(Ambience ambience) async {
    if (_hasActiveSession && _ambience?.id == ambience.id) return;

    await stopInternal(alsoClearPersistence: false);
    _setSession(ambience, elapsed: 0, isPlaying: false);
    await _loadAudioAndSeek(ambience.audioAsset, targetElapsedSeconds: 0);
    await play();
  }

  Future<void> _loadAudioAndSeek(
    String audioAsset, {
    required int targetElapsedSeconds,
  }) async {
    try {
      _audioError = null;
      if (audioAsset.trim().isEmpty) {
        throw const FormatException('Missing audioAsset in ambience JSON.');
      }

      await _audioPlayer.setAudioSource(AudioSource.asset(audioAsset));
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(1.0);

      final duration = _audioPlayer.duration;
      _audioDurationSeconds = duration?.inSeconds ?? 0;

      if (_audioDurationSeconds > 0) {
        final audioSeconds = targetElapsedSeconds % _audioDurationSeconds;
        await _audioPlayer.seek(Duration(seconds: audioSeconds));
      }

      notifyListeners();
    } catch (e) {
      _audioError = e.toString();
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (!_hasActiveSession || _ambience == null) return;

    try {
      await _audioPlayer.play();
    } catch (_) {}

    _isPlaying = true;
    _startTicker();
    notifyListeners();
    await _persistState(
      ActiveSessionState(
        ambience: _ambience!,
        elapsedSeconds: _elapsedSeconds,
        isPlaying: true,
        lastUpdatedEpochMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> pause() async {
    if (!_hasActiveSession) return;

    _isPlaying = false;
    _stopTicker();
    try {
      await _audioPlayer.pause();
    } catch (_) {}
    notifyListeners();

    if (_ambience != null) {
      await _persistState(
        ActiveSessionState(
          ambience: _ambience!,
          elapsedSeconds: _elapsedSeconds,
          isPlaying: false,
          lastUpdatedEpochMillis: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_hasActiveSession) return;
      _elapsedSeconds += 1;

      if (_ambience != null) {
        unawaited(
          _persistState(
            ActiveSessionState(
              ambience: _ambience!,
              elapsedSeconds: _elapsedSeconds,
              isPlaying: _isPlaying,
              lastUpdatedEpochMillis: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
      }

      if (_ambience != null && _elapsedSeconds >= _ambience!.durationSeconds) {
        unawaited(endSession(reason: SessionEndReason.completed));
      } else {
        notifyListeners();
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> seekToSessionElapsedSeconds(int elapsedSeconds) async {
    if (!_hasActiveSession || _ambience == null) return;
    final clamped = elapsedSeconds.clamp(0, _ambience!.durationSeconds);
    _elapsedSeconds = clamped;

    if (_audioDurationSeconds > 0) {
      try {
        final audioSeconds = _elapsedSeconds % _audioDurationSeconds;
        await _audioPlayer.seek(Duration(seconds: audioSeconds));
      } catch (_) {}
    }

    notifyListeners();
    await _persistState(
      ActiveSessionState(
        ambience: _ambience!,
        elapsedSeconds: _elapsedSeconds,
        isPlaying: _isPlaying,
        lastUpdatedEpochMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> endSession({required SessionEndReason reason}) async {
    _endEventId += 1;
    _stopTicker();
    _isPlaying = false;
    _hasActiveSession = false;

    try {
      await _audioPlayer.pause();
      await _audioPlayer.seek(Duration.zero);
    } catch (_) {}

    await _clearPersistedState();
    _ambience = null;
    _elapsedSeconds = 0;
    _audioDurationSeconds = 0;
    _audioError = null;
    notifyListeners();
  }

  Future<void> stopInternal({required bool alsoClearPersistence}) async {
    _stopTicker();
    _isPlaying = false;
    _hasActiveSession = false;

    try {
      await _audioPlayer.pause();
      await _audioPlayer.seek(Duration.zero);
    } catch (_) {}

    if (alsoClearPersistence) {
      await _clearPersistedState();
    }

    _ambience = null;
    _elapsedSeconds = 0;
    _audioDurationSeconds = 0;
    _audioError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    _audioPlayer.dispose();
    super.dispose();
  }
}
