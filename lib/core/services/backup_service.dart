import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Export remindo_local.db by temporarily closing DB and sharing via system share sheet
  Future<bool> exportDatabase() async {
    try {
      final dbPath = await _dbHelper.getDatabasePath();
      final file = File(dbPath);

      if (!await file.exists()) {
        return false;
      }

      // Close DB connection to flush WAL and avoid locks
      await _dbHelper.close();

      await Share.shareXFiles(
        [XFile(dbPath, mimeType: 'application/x-sqlite3', name: 'remindo_backup.db')],
        text: 'Backup Database Remindo (Offline)',
      );

      // Re-initialize DB
      await _dbHelper.database;
      return true;
    } catch (_) {
      await _dbHelper.database;
      return false;
    }
  }

  /// Import/Restore remindo_local.db:
  /// Validates "SQLite format 3" header before replacing the file
  Future<bool> importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final pickedFile = File(result.files.single.path!);
      if (!await pickedFile.exists()) return false;

      // Validate SQLite header: "SQLite format 3" (first 16 bytes)
      final bytes = await pickedFile.openRead(0, 16).first;
      final header = String.fromCharCodes(bytes);
      if (!header.startsWith('SQLite format 3')) {
        return false; // Not a valid SQLite database file
      }

      final targetPath = await _dbHelper.getDatabasePath();

      // Close existing DB
      await _dbHelper.close();

      // Overwrite local db with imported backup
      await pickedFile.copy(targetPath);

      // Re-open DB
      await _dbHelper.database;
      return true;
    } catch (_) {
      await _dbHelper.database;
      return false;
    }
  }
}
