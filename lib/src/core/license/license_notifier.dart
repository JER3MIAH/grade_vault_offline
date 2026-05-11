import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';

/// Thin provider that exposes the school info from the app state.
/// Kept for compatibility with existing widgets.
final licenseProvider = Provider<SchoolInfo>((ref) {
  return ref.watch(appStateProvider.select((s) => s.schoolInfo));
});
