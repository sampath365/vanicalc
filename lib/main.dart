import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app_providers.dart';
import 'features/history/data/history_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  final historyBox = await Hive.openBox<dynamic>(HistoryRepository.boxName);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        historyBoxProvider.overrideWithValue(historyBox),
      ],
      child: const VaniCalcApp(),
    ),
  );
}
