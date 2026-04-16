import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ambience_library_provider.dart';
import '../providers/session_player_provider.dart';
import '../widgets/ambience_card.dart';
import '../widgets/ambience_tag_chip.dart';
import '../widgets/mini_player.dart';
import 'ambience_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectTag(BuildContext context, String tag) {
    if (tag == 'Reset') {
      context.read<AmbienceLibraryProvider>().resetFilters();
      _searchController.text = '';
      return;
    }
    context.read<AmbienceLibraryProvider>().filterByTag(tag);
  }

  void _onSearchChanged(BuildContext context, String query) {
    context.read<AmbienceLibraryProvider>().setQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final tagLabels = const <String>['Focus', 'Calm', 'Sleep', 'Reset'];

    return Scaffold(
      body: SafeArea(
        child: Consumer<AmbienceLibraryProvider>(
          builder: (context, state, _) {
            Widget content;

            if (state.isLoading) {
              content = const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              content = Center(
                child: Text(
                  'Failed to load ambiences: ${state.error}',
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state.filteredAmbiences.isEmpty) {
              content = const Center(child: Text('No ambiences found'));
            } else {
              content = LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 900 ? 3 : (width >= 600 ? 2 : 1);

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: state.filteredAmbiences.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      final ambience = state.filteredAmbiences[index];
                      return AmbienceCard(
                        ambience: ambience,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  AmbienceDetailsScreen(ambience: ambience),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambience Library',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => _onSearchChanged(context, v),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tagLabels.map((label) {
                            final selected = state.selectedTag == null
                                ? label == 'Reset'
                                : state.selectedTag == label;

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: AmbienceTagChip(
                                label: label,
                                isSelected: selected,
                                onSelected: () => _onSelectTag(context, label),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            );
          },
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
