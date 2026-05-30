import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'data/repositories/hive_transfer_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/providers/transfer_providers.dart';
import 'presentation/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ar';

  // ─── تهيئة Hive ───────────────────────────────────────────────────────────
  final repository = HiveTransferRepository();
  await repository.init();

  // ─── تهيئة الإعدادات ──────────────────────────────────────────────────────
  final settingsRepo = SettingsRepository.instance;
  await settingsRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        transferRepositoryProvider.overrideWithValue(repository),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
      child: const AkabiApp(),
    ),
  );
}
