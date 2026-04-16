import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/journal_provider.dart';
import '../providers/session_player_provider.dart';
import '../widgets/mini_player.dart';
import 'journal_entry_detail_screen.dart';

class JournalHistoryScreen extends StatelessWidget {
  const JournalHistoryScreen({super.key});

  String _formatDateTime(int epochMillis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal History')),
      bottomNavigationBar: Consumer<SessionPlayerProvider>(
        builder: (context, player, _) {
          if (!player.hasActiveSession || player.ambience == null) {
            return const SizedBox.shrink();
          }
          return MiniPlayer(ambience: player.ambience!);
        },
      ),
      body: SafeArea(
        child: Consumer<JournalProvider>(
          builder: (context, journal, _) {
            if (journal.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (journal.error != null) {
              return Center(child: Text('Failed to load: ${journal.error}'));
            }
            if (journal.entries.isEmpty) {
              return const Center(child: Text('No reflections yet'));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: journal.entries.length,
              separatorBuilder: (context, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final entry = journal.entries[i];
                final preview = entry.reflectionText.length > 120
                    ? '${entry.reflectionText.substring(0, 120)}...'
                    : entry.reflectionText;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => JournalEntryDetailScreen(entry: entry),
                        ),
                      );
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDateTime(entry.createdAtEpochMillis),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.ambienceTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.mood,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black45,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            preview,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
