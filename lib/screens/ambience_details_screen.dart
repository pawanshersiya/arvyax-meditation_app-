import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ambience.dart';
import '../providers/session_player_provider.dart';
import '../widgets/mini_player.dart';
import 'session_player_screen.dart';

class AmbienceDetailsScreen extends StatelessWidget {
  const AmbienceDetailsScreen({
    super.key,
    required this.ambience,
  });

  final Ambience ambience;

  String _formatDuration(int durationSeconds) {
    if (durationSeconds >= 60) {
      final minutes = durationSeconds ~/ 60;
      return '$minutes min';
    }
    return '$durationSeconds sec';
  }

  @override
  Widget build(BuildContext context) {
    final sensory = ambience.sensory.isNotEmpty ? ambience.sensory : const <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(ambience.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    ambience.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, size: 42),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ambience.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(ambience.tag),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.14),
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text(_formatDuration(ambience.durationSeconds)),
                    backgroundColor: Colors.white.withValues(alpha: 0.45),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(ambience.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Text(
                'Sensory',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sensory.map((s) {
                  return Chip(
                    label: Text(s),
                    backgroundColor: Colors.white.withValues(alpha: 0.40),
                  );
                }).toList(),
              ),
              if (sensory.isEmpty) ...[const Text('')],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SessionPlayerScreen(ambience: ambience),
                      ),
                    );
                  },
                  child: const Text('Start Session'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer<SessionPlayerProvider>(
        builder: (context, player, _) {
          if (!player.hasActiveSession || player.ambience == null) {
            return const SizedBox.shrink();
          }
          return MiniPlayer(ambience: player.ambience!);
        },
      ),
    );
  }
}
