import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ambience.dart';
import '../providers/session_player_provider.dart';
import 'reflection_screen.dart';

class SessionPlayerScreen extends StatefulWidget {
  const SessionPlayerScreen({
    super.key,
    required this.ambience,
  });

  final Ambience ambience;

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  bool _started = false;
  bool _navigatedToReflection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _started = true;
      context.read<SessionPlayerProvider>().startSession(widget.ambience);
    });
  }

  String _formatTime(int seconds) {
    final clamped = seconds.clamp(0, 86400);
    final m = clamped ~/ 60;
    final s = clamped % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _confirmEndSession() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End session?'),
          content: const Text('Are you sure you want to end this session now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('End'),
            ),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      context.read<SessionPlayerProvider>().endSession(
            reason: SessionEndReason.manual,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ambience.title),
        actions: [
          IconButton(
            tooltip: 'End session',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: _confirmEndSession,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SessionPlayerProvider>(
          builder: (context, playerState, _) {
            final total = playerState.sessionDurationSeconds;
            final elapsed = playerState.elapsedSeconds;
            final hasSlider = total > 0;

            if (_started &&
                !_navigatedToReflection &&
                !playerState.hasActiveSession) {
              _navigatedToReflection = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => ReflectionScreen(ambience: widget.ambience),
                  ),
                );
              });
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.ambience.tag,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(elapsed),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        _formatTime(total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasSlider)
                    Slider(
                      value: elapsed.clamp(0, total).toDouble(),
                      min: 0,
                      max: total.toDouble(),
                      onChanged: (v) {
                        unawaited(playerState.seekToSessionElapsedSeconds(v.round()));
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  if (playerState.audioError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Audio not available. Timer will still end the session.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.redAccent,
                          ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.self_improvement_outlined,
                            size: 74,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Breathe softly',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'playPause',
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          playerState.togglePlayPause();
                        },
                        child: Icon(
                          playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _confirmEndSession,
                      child: const Text('End Session'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
