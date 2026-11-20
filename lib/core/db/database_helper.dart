import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = "remindo_local.db";
  static const int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasePath();
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. hero_profile
    await db.execute('''
      CREATE TABLE hero_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        xp INTEGER NOT NULL DEFAULT 0,
        xp_next INTEGER NOT NULL DEFAULT 100,
        coins INTEGER NOT NULL DEFAULT 0,
        streak_days INTEGER NOT NULL DEFAULT 0,
        room_level INTEGER NOT NULL DEFAULT 1,
        active_costume_id TEXT NOT NULL DEFAULT 'hoodie_ungu',
        active_pet_id TEXT NOT NULL DEFAULT 'cat_tuxedo',
        last_active_date TEXT
      )
    ''');

    // 2. quests
    await db.execute('''
      CREATE TABLE quests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        coin_reward INTEGER NOT NULL,
        is_timed INTEGER NOT NULL DEFAULT 0,
        duration_minutes INTEGER NOT NULL DEFAULT 25,
        alarm_time TEXT,
        repeat_rule TEXT DEFAULT 'once',
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. quest_history
    await db.execute('''
      CREATE TABLE quest_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quest_id INTEGER,
        title TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        xp_earned INTEGER NOT NULL,
        coin_earned INTEGER NOT NULL,
        focus_minutes INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 4. transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. savings_goals
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount INTEGER NOT NULL,
        saved_amount INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. notification_settings
    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        is_enabled INTEGER NOT NULL DEFAULT 1,
        display_mode TEXT NOT NULL DEFAULT 'auto',
        daily_enabled INTEGER NOT NULL DEFAULT 1,
        daily_days TEXT NOT NULL DEFAULT '["Sen","Rab","Jum"]',
        daily_time TEXT NOT NULL DEFAULT '20:00',
        monthly_enabled INTEGER NOT NULL DEFAULT 1,
        monthly_day TEXT NOT NULL DEFAULT 'last',
        monthly_time TEXT NOT NULL DEFAULT '09:00',
        title TEXT NOT NULL DEFAULT 'Laporan Dompetku',
        message TEXT NOT NULL DEFAULT 'Cek ringkasan uang jajanmu hari ini!',
        include_income INTEGER NOT NULL DEFAULT 1,
        include_expense INTEGER NOT NULL DEFAULT 1,
        include_balance INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 7. custom_assets
    await db.execute('''
      CREATE TABLE custom_assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_type TEXT NOT NULL,
        slot_key TEXT NOT NULL,
        local_file_path TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(folder_type, slot_key)
      )
    ''');

    // 8. app_settings
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // --- SEED INITIAL DATA ---
    final now = DateTime.now().toIso8601String();

    // Default Hero Profile
    await db.insert('hero_profile', {
      'id': 1,
      'name': 'Hero Remindo',
      'level': 1,
      'xp': 0,
      'xp_next': 100,
      'coins': 150,
      'streak_days': 1,
      'room_level': 1,
      'active_costume_id': 'hoodie_ungu',
      'active_pet_id': 'cat_tuxedo',
      'last_active_date': now.split('T').first,
    });

    // Default Notification Settings
    await db.insert('notification_settings', {
      'id': 1,
      'is_enabled': 1,
      'display_mode': 'auto',
      'daily_enabled': 1,
      'daily_days': '["Sen","Rab","Jum"]',
      'daily_time': '20:00',
      'monthly_enabled': 1,
      'monthly_day': 'last',
      'monthly_time': '09:00',
      'title': 'Laporan Dompetku',
      'message': 'Cek ringkasan uang jajanmu hari ini!',
      'include_income': 1,
      'include_expense': 1,
      'include_balance': 1,
    });

    // Default App Settings
    await db.insert('app_settings', {'key': 'floating_sticker_enabled', 'value': 'true'});
    await db.insert('app_settings', {'key': 'remote_catalog_version', 'value': '1'});
    await db.insert('app_settings', {'key': 'focus_music_enabled', 'value': 'true'});
    await db.insert('app_settings', {'key': 'app_theme', 'value': 'pixel_retro'});

    // Starter Quests
    await db.insert('quests', {
      'title': 'Fokus Belajar 25 Menit',
      'category': 'daily',
      'difficulty': 'normal',
      'xp_reward': 50,
      'coin_reward': 30,
      'is_timed': 1,
      'duration_minutes': 25,
      'alarm_time': null,
      'repeat_rule': 'daily',
      'is_completed': 0,
      'created_at': now,
    });

    await db.insert('quests', {
      'title': 'Minum Air Putih 8 Gelas',
      'category': 'daily',
      'difficulty': 'easy',
      'xp_reward': 20,
      'coin_reward': 15,
      'is_timed': 0,
      'duration_minutes': 0,
      'alarm_time': '12:00',
      'repeat_rule': 'daily',
      'is_completed': 0,
      'created_at': now,
    });

    // Starter Savings Goal
    await db.insert('savings_goals', {
      'title': 'Buku Kuliah & Catatan',
      'target_amount': 250000,
      'saved_amount': 50000,
      'created_at': now,
    });

    // Starter Transactions
    await db.insert('transactions', {
      'type': 'income',
      'amount': 300000,
      'category': 'Uang Saku',
      'note': 'Uang saku bulanan awal',
      'created_at': now,
    });

    await db.insert('transactions', {
      'type': 'expense',
      'amount': 50000,
      'category': 'Tabungan',
      'note': 'Setoran awal Buku Kuliah',
      'created_at': now,
    });
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
