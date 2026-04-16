import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ambience.dart';
import '../providers/journal_provider.dart';
import '../providers/session_player_provider.dart';
import '../widgets/mini_player.dart';
import 'journal_history_screen.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.ambience,
  });

  final Ambience ambience;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _controller = TextEditingController();
  JournalMood? _selectedMood;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final journal = context.read<JournalProvider>();
    final text = _controller.text.trim();

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a mood.')),
      );
      return;
    }
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reflection before saving.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await journal.addReflection(
        ambience: widget.ambience,
        mood: _selectedMood!,
        reflectionText: text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reflection: $e')),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const JournalHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflection')),
      bottomNavigationBar: Consumer<SessionPlayerProvider>(
        builder: (context, player, _) {
          if (!player.hasActiveSession || player.ambience == null) {
            return const SizedBox.shrink();
          }
          return MiniPlayer(ambience: player.ambience!);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is gently present with you right now?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 8,
                minLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Write your reflection...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mood',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: JournalMood.values.map((m) {
                  final selected = _selectedMood == m;
                  return ChoiceChip(
                    label: Text(m.label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedMood = m;
                      });
                    },
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.18),
                    backgroundColor: Colors.white.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Ambience: ${widget.ambience.title}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
