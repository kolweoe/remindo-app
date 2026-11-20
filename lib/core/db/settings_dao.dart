import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/notification_settings.dart';

class SettingsDao {
  final DatabaseHelper dbHelper;

  SettingsDao({DatabaseHelper? helper}) : dbHelper = helper ?? DatabaseHelper.instance;

  Future<NotificationSettings> getNotificationSettings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notification_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return NotificationSettings.fromMap(maps.first);
    }

    final defaultSettings = NotificationSettings();
    await db.insert('notification_settings', defaultSettings.toMap());
    return defaultSettings;
  }

  Future<int> updateNotificationSettings(NotificationSettings settings) async {
    final db = await dbHelper.database;
    return await db.update(
      'notification_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String> getSetting(String key, {String defaultValue = ''}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return defaultValue;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await dbHelper.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('app_settings');
    final Map<String, String> result = {};
    for (final m in maps) {
      result[m['key'] as String] = m['value'] as String;
    }
    return result;
  }

  Future<String?> getCustomAsset(String folderType, String slotKey) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_assets',
      where: 'folder_type = ? AND slot_key = ?',
      whereArgs: [folderType, slotKey],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['local_file_path'] as String;
    }
    return null;
  }

  Future<void> upsertCustomAsset(String folderType, String slotKey, String localFilePath) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'custom_assets',
      {
        'folder_type': folderType,
        'slot_key': slotKey,
        'local_file_path': localFilePath,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllCustomAssets() async {
    final db = await dbHelper.database;
    return await db.query('custom_assets');
  }
}
