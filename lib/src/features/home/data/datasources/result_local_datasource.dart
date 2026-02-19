import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/core/constants/term_list.dart';
import 'package:grade_vault_offline/src/features/home/data/models/class_section.dart';
import 'package:grade_vault_offline/src/features/home/data/models/old/result_model.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student.dart';
import 'package:grade_vault_offline/src/features/home/data/models/student_record.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultLocalDatasource {
  final SharedPreferences? prefs;
  final Box? hiveBox;

  static const String _appStateKey = 'app_state';
  static const String _oldAppStateKey = 'result';
  static const String _hiveBoxName = 'grade_vault_offline_storage';
  static const String _migrationFlagKey = 'migration_completed';

  ResultLocalDatasource({this.prefs, this.hiveBox});

  /// Initialize Hive box (call this during app startup after Hive.initFlutter())
  static Future<Box> initializeHive() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AppStateAdapter());
      }
      final box = await Hive.openBox(_hiveBoxName);
      return box;
    } catch (e) {
      log('Error initializing Hive: $e');
      rethrow;
    }
  }

  Future<AppState?> getAppState() async {
    try {
      // Try Hive first (new storage)
      if (hiveBox != null) {
        final String? json = hiveBox!.get(_appStateKey);
        if (json != null) {
          return AppState.fromJson(json);
        }

        // Check if migration was already done but no data exists yet
        final bool migrationDone = hiveBox!.get(
          _migrationFlagKey,
          defaultValue: false,
        );
        if (migrationDone) {
          return null; // Migration done but no state, return null
        }
      }

      // Fallback to SharedPreferences for legacy users
      if (prefs != null) {
        String? json = prefs!.getString(_appStateKey);
        if (json != null) {
          await _migrateToHive(json);
          return AppState.fromJson(json);
        }

        // Backward compatibility: try loading old stored state
        final String? oldJson = prefs!.getString(_oldAppStateKey);
        if (oldJson != null) {
          try {
            final migrated = await _migrateFromOldFormat(oldJson);
            await _migrateToHive(migrated.toJson());
            return migrated;
          } catch (e, stack) {
            log('error migrating old state: $e at $stack');
            return null;
          }
        }
      }

      return null;
    } catch (e, stack) {
      log('error getting app state: $e at $stack');
      return null;
    }
  }

  /// Migrate from old ResultModel format to new AppState format
  Future<AppState> _migrateFromOldFormat(String oldJson) async {
    final ResultModel oldState = ResultModel.fromJson(oldJson);

    // Convert old single-class ResultModel to new AppState
    const legacyClassId = 'legacy_class';

    final List<ClassSection> classSections = [
      ClassSection(
        id: legacyClassId,
        name: oldState.className,
        teacherName: oldState.teacherName,
        branch: oldState.branch,
        session: oldState.session,
        subjectNames: oldState.subjectList,
      ),
    ];

    final List<StudentRecord> studentRecords = oldState.studentList.map((s) {
      // Initialize all three terms
      final List<TermResult> termResults = TERM_LIST.map((termName) {
        if (termName == TERM_LIST.first) {
          // First term: use existing scores from old data
          return TermResult(
            termName: termName,
            subjects: s.subjectPerformances,
            teacherComment: s.teacherComment,
            principalComment: s.principalComment,
          );
        } else {
          // Second and Third terms: initialize with class subjects at 0
          return TermResult(
            termName: termName,
            subjects: oldState.subjectList
                .map(
                  (subjectName) => SubjectPerformance(
                    subjectName: subjectName,
                    caScore: 0,
                    examScore: 0,
                  ),
                )
                .toList(),
            teacherComment: '',
            principalComment: '',
          );
        }
      }).toList();

      return StudentRecord(
        student: Student(id: s.id, name: s.name, gender: s.gender, age: s.age),
        classId: legacyClassId,
        termResults: termResults,
      );
    }).toList();

    return AppState(
      schoolInfo: oldState.schoolInfo.copyWith(logoPath: sunflowerIcon),
      currentTerm: TERM_LIST.first,
      classSections: classSections,
      studentRecords: studentRecords,
      selectedClassId: legacyClassId,
      selectedStudentId: '',
    );
  }

  /// Migrate data from SharedPreferences to Hive
  Future<void> _migrateToHive(String appStateJson) async {
    try {
      if (hiveBox == null) return;

      // Store in Hive
      await hiveBox!.put(_appStateKey, appStateJson);

      // Mark migration as complete
      await hiveBox!.put(_migrationFlagKey, true);

      // Clean up old SharedPreferences data (optional, can be removed later)
      if (prefs != null) {
        // Don't delete immediately to avoid issues with concurrent access
        // Data will be cleaned up in a separate maintenance task
        log('Migration to Hive completed successfully');
      }
    } catch (e, stack) {
      log('error migrating to Hive: $e at $stack');
    }
  }

  Future<void> setAppState(AppState state) async {
    try {
      String json = state.toJson();

      // Save to Hive (preferred)
      if (hiveBox != null) {
        await hiveBox!.put(_appStateKey, json);
        return;
      }

      // Fallback to SharedPreferences for legacy cases
      if (prefs != null) {
        await prefs!.setString(_appStateKey, json);
      }
    } catch (e, stack) {
      log('error saving app state: $e at $stack');
    }
  }

  /// Clean up old SharedPreferences data after successful migration
  Future<void> cleanupLegacyStorage() async {
    try {
      if (prefs == null || hiveBox == null) return;

      final bool migrationDone = hiveBox!.get(
        _migrationFlagKey,
        defaultValue: false,
      );
      if (!migrationDone) return;

      // Only clean if data exists in Hive
      if (hiveBox!.containsKey(_appStateKey)) {
        await prefs!.remove(_appStateKey);
        await prefs!.remove(_oldAppStateKey);
        log('Legacy storage cleaned up successfully');
      }
    } catch (e, stack) {
      log('error cleaning up legacy storage: $e at $stack');
    }
  }
}

// Hive Adapter for AppState (TypeId: 0)
class AppStateAdapter extends TypeAdapter<AppState> {
  @override
  final int typeId = 0;

  @override
  AppState read(BinaryReader reader) {
    // Hive stores as JSON string, so we deserialize it
    final jsonString = reader.read() as String;
    return AppState.fromJson(jsonString);
  }

  @override
  void write(BinaryWriter writer, AppState obj) {
    // Serialize to JSON string for storage
    writer.write(obj.toJson());
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final resultLocalDatasourceProvider = Provider<ResultLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final hiveBox = ref.watch(hiveBoxProvider);
  return ResultLocalDatasource(prefs: prefs, hiveBox: hiveBox);
});
