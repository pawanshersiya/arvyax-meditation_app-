import 'package:flutter/material.dart';

import '../models/ambience.dart';

String _formatDuration(int durationSeconds) {
  if (durationSeconds >= 60) {
    final minutes = (durationSeconds ~/ 60).toString();
    return '$minutes min';
  }
  return '$durationSeconds sec';
}

class AmbienceCard extends StatelessWidget {
  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  final Ambience ambience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final durationText = _formatDuration(ambience.durationSeconds);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    ambience.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ambience.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${ambience.tag} • $durationText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
