import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grade_vault_offline/src/app.dart';
import 'package:grade_vault_offline/src/core/config/app_config.dart';
import 'package:grade_vault_offline/src/features/home/data/datasources/result_local_datasource.dart';
import 'package:grade_vault_offline/src/core/utils/loading_indicator_remover.dart'
    if (dart.library.js_interop) 'package:grade_vault_offline/src/core/utils/loading_indicator_remover_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (must be called before opening boxes)
  await Hive.initFlutter();

  // Initialize storage
  final hiveBox = await ResultLocalDatasource.initializeHive();

  await AppConfig.load();

  runApp(
    ProviderScope(
      overrides: [hiveBoxProvider.overrideWithValue(hiveBox)],
      child: const MyApp(),
    ),
  );

  removeLoadingIndicator();
}
