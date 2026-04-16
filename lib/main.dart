import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/ambience_repository.dart';
import 'core/journal_repository.dart';
import 'providers/ambience_library_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/session_player_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AmbienceRepository>(create: (_) => AssetAmbienceRepository()),
        ChangeNotifierProvider<AmbienceLibraryProvider>(
          create: (context) => AmbienceLibraryProvider(
            repository: context.read<AmbienceRepository>(),
          )..load(),
        ),
        ChangeNotifierProvider<SessionPlayerProvider>(
          create: (_) => SessionPlayerProvider(),
        ),
        Provider<JournalRepository>(create: (_) => HiveJournalRepository()),
        ChangeNotifierProvider<JournalProvider>(
          create: (context) =>
              JournalProvider(repository: context.read<JournalRepository>())
                ..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Arvyax',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.calm,
        home: const HomeScreen(),
      ),
    );
  }
}
