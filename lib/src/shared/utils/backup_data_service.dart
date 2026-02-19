import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/shared/utils/get_dir.dart';
import 'package:grade_vault_offline/src/shared/utils/get_unique_id.dart';
import 'package:grade_vault_offline/src/shared/utils/share_helper.dart';
import 'save_file_stub.dart' if (dart.library.js_interop) 'save_file_web.dart';

/// Service for handling backup and restore operations for app data
class BackupDataService {
  /// Export student records and classes to a JSON file
  /// Returns the file path on success, null on failure
  /// For Windows: saves to downloads folder
  /// For Android/iOS: shares using share API
  Future<String?> exportData({
    required List<ClassSection> classes,
    required List<StudentRecord> students,
  }) async {
    try {
      final exportData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'classes': classes.map((c) => c.toMap()).toList(),
        'students': students.map((s) => s.toMap()).toList(),
      };

      final jsonString = jsonEncode(exportData);
      final fileName =
          'grade_vault_offline_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        await _exportToWeb(jsonString, fileName);
        return 'Downloads'; // Web doesn't have a specific path
      }

      if (Platform.isWindows) {
        return await _exportToDownloads(jsonString, fileName);
      } else if (Platform.isAndroid || Platform.isIOS) {
        await _shareExport(jsonString, fileName);
        return 'External'; // Shared via share API
      } else if (Platform.isLinux || Platform.isMacOS) {
        return await _exportToDownloads(jsonString, fileName);
      }

      return null;
    } catch (e, stack) {
      log('Error exporting data: $e\nStack: $stack');
      return null;
    }
  }

  /// Import student records and classes from a JSON file
  /// Returns a tuple of (importedClasses, importedStudents, duplicateInfo)
  /// Handles duplicates by ignoring them or assigning new IDs
  Future<
    ({
      List<ClassSection> classes,
      List<StudentRecord> students,
      String duplicateInfo,
    })?
  >
  importData({
    required List<ClassSection> existingClasses,
    required List<StudentRecord> existingStudents,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        log('No file selected');
        return null;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        log('Could not read file data');
        return null;
      }

      final jsonString = utf8.decode(file.bytes!);
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Invalid JSON format: Expected a JSON object');
      }

      // Parse classes
      List<ClassSection> importedClasses = [];
      if (jsonData['classes'] != null) {
        final classList = jsonData['classes'] as List<dynamic>?;
        if (classList != null) {
          importedClasses = classList
              .map((c) => ClassSection.fromMap(c as Map<String, dynamic>))
              .toList();
        }
      }

      // Parse students
      List<StudentRecord> importedStudents = [];
      if (jsonData['students'] != null) {
        final studentList = jsonData['students'] as List<dynamic>?;
        if (studentList != null) {
          importedStudents = studentList
              .map((s) => StudentRecord.fromMap(s as Map<String, dynamic>))
              .toList();
        }
      }

      // Handle duplicates
      final resultData = _mergeDuplicates(
        existingClasses: existingClasses,
        importedClasses: importedClasses,
        existingStudents: existingStudents,
        importedStudents: importedStudents,
      );

      return resultData;
    } catch (e, stack) {
      log('Error importing data: $e\nStack: $stack');
      return null;
    }
  }

  /// Merge imported data with existing data, handling duplicates
  ({
    List<ClassSection> classes,
    List<StudentRecord> students,
    String duplicateInfo,
  })
  _mergeDuplicates({
    required List<ClassSection> existingClasses,
    required List<ClassSection> importedClasses,
    required List<StudentRecord> existingStudents,
    required List<StudentRecord> importedStudents,
  }) {
    final mergedClasses = List<ClassSection>.from(existingClasses);
    final mergedStudents = List<StudentRecord>.from(existingStudents);
    final duplicateInfo = StringBuffer();

    // Process classes
    for (final importedClass in importedClasses) {
      final existingIndex = mergedClasses.indexWhere(
        (c) => _classesAreEqual(c, importedClass),
      );

      if (existingIndex >= 0) {
        // Duplicate class found
        duplicateInfo.writeln(
          'Skipped duplicate class: ${importedClass.name} (${importedClass.branch})',
        );
      } else {
        mergedClasses.add(importedClass);
      }
    }

    // Process students
    for (final importedStudent in importedStudents) {
      final existingIndex = mergedStudents.indexWhere(
        (s) => _studentsAreEqual(s, importedStudent),
      );

      if (existingIndex >= 0) {
        // Duplicate student found - check if data is different
        final existingStudent = mergedStudents[existingIndex];
        if (_studentRecordsAreEqual(existingStudent, importedStudent)) {
          duplicateInfo.writeln(
            'Skipped duplicate student: ${importedStudent.student.name}',
          );
        } else {
          // Different data - assign new ID and add as new record
          final newStudent = importedStudent.copyWith(
            student: importedStudent.student.copyWith(id: getUniqueId()),
          );
          mergedStudents.add(newStudent);
          duplicateInfo.writeln(
            'Added ${importedStudent.student.name} with new ID (data conflict)',
          );
        }
      } else {
        mergedStudents.add(importedStudent);
      }
    }

    return (
      classes: mergedClasses,
      students: mergedStudents,
      duplicateInfo: duplicateInfo.toString().trim(),
    );
  }

  /// Check if two classes are equal (by key attributes)
  bool _classesAreEqual(ClassSection c1, ClassSection c2) {
    return c1.name == c2.name &&
        c1.branch == c2.branch &&
        c1.session == c2.session;
  }

  /// Check if two student records have the same student (by key attributes)
  bool _studentsAreEqual(StudentRecord s1, StudentRecord s2) {
    return s1.student.name == s2.student.name && s1.classId == s2.classId;
  }

  /// Check if two student records are completely equal
  bool _studentRecordsAreEqual(StudentRecord s1, StudentRecord s2) {
    if (s1.student.name != s2.student.name || s1.classId != s2.classId) {
      return false;
    }
    if (s1.termResults.length != s2.termResults.length) {
      return false;
    }
    // Compare term results
    for (int i = 0; i < s1.termResults.length; i++) {
      if (s1.termResults[i].toJson() != s2.termResults[i].toJson()) {
        return false;
      }
    }
    return true;
  }

  /// Export data to downloads folder (Windows, Linux, macOS)
  /// Returns the file path
  Future<String?> _exportToDownloads(String jsonString, String fileName) async {
    try {
      final dir = await getDir();
      if (dir == null) {
        log('Could not access downloads directory');
        return null;
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      log('Backup exported to: ${file.path}');
      return file.path;
    } catch (e, stack) {
      log('Error exporting to downloads: $e\nStack: $stack');
      return null;
    }
  }

  /// Share export file (Android, iOS)
  Future<bool> _shareExport(String jsonString, String fileName) async {
    try {
      // Write to temporary file
      final dir = await getDir();
      if (dir == null) {
        log('Could not access app documents directory');
        return false;
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await ShareHelper.shareFile(file.path);
      return true;
    } catch (e, stack) {
      log('Error sharing export: $e\nStack: $stack');
      return false;
    }
  }

  /// Export data to web (triggers download in browser)
  Future<bool> _exportToWeb(String jsonString, String fileName) async {
    try {
      final bytes = Uint8List.fromList(jsonString.codeUnits);
      saveFileWeb(bytes, fileName, mimeType: 'application/json');
      log('Backup exported to web download');
      return true;
    } catch (e, stack) {
      log('Error exporting to web: $e\nStack: $stack');
      return false;
    }
  }
}
