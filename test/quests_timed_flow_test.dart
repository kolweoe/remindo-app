import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:remindo_app/core/db/hero_dao.dart';
import 'package:remindo_app/core/db/quest_dao.dart';
import 'package:remindo_app/core/db/database_helper.dart';
import 'package:remindo_app/models/quest.dart';

class TestDatabaseHelper implements DatabaseHelper {
  final Database _db;
  TestDatabaseHelper(this._db);

  @override
  Future<Database> get database async => _db;

  @override
  Future<void> close() async => await _db.close();

  @override
  Future<String> getDatabasePath() async => inMemoryDatabasePath;
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late HeroDao heroDao;
  late QuestDao questDao;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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

          await db.execute('''
            CREATE TABLE app_settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    final helper = TestDatabaseHelper(db);
    heroDao = HeroDao(helper: helper);
    questDao = QuestDao(helper: helper, hero: heroDao);

    // Create initial hero
    await heroDao.createInitialHero(
      name: 'Raka Tester',
      starterAvatar: 'hoodie_ungu',
      focusGoal: 'Kuliah',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('Aturan 3 Tingkat Kesulitan Hadiah XP & Coin Berbeda', () {
    // 1. Easy: Pengingat (+15 XP, +10 Coin) vs Ber-Timer (+25 XP, +15 Coin)
    final easyReminder = HeroDao.calculateQuestReward(difficulty: 'easy', isTimed: false);
    final easyTimed = HeroDao.calculateQuestReward(difficulty: 'easy', isTimed: true);
    expect(easyReminder['xp'], equals(15));
    expect(easyReminder['coins'], equals(10));
    expect(easyTimed['xp'], equals(25));
    expect(easyTimed['coins'], equals(15));

    // 2. Normal: Pengingat (+30 XP, +20 Coin) vs Ber-Timer (+50 XP, +35 Coin)
    final normalReminder = HeroDao.calculateQuestReward(difficulty: 'normal', isTimed: false);
    final normalTimed = HeroDao.calculateQuestReward(difficulty: 'normal', isTimed: true);
    expect(normalReminder['xp'], equals(30));
    expect(normalReminder['coins'], equals(20));
    expect(normalTimed['xp'], equals(50));
    expect(normalTimed['coins'], equals(35));

    // 3. Hard: Pengingat (+60 XP, +40 Coin) vs Ber-Timer (+100 XP, +70 Coin)
    final hardReminder = HeroDao.calculateQuestReward(difficulty: 'hard', isTimed: false);
    final hardTimed = HeroDao.calculateQuestReward(difficulty: 'hard', isTimed: true);
    expect(hardReminder['xp'], equals(60));
    expect(hardReminder['coins'], equals(40));
    expect(hardTimed['xp'], equals(100));
    expect(hardTimed['coins'], equals(70));
  });

  test('Alur Quest Pengingat: Centang Langsung & Hadiah Masuk SQLite', () async {
    final now = DateTime.now().toIso8601String();

    // Insert Quest Pengingat (Easy)
    final questId = await questDao.insertQuest(
      Quest(
        title: 'Minum Air Putih',
        category: 'daily',
        difficulty: 'easy',
        xpReward: 15,
        coinReward: 10,
        isTimed: false,
        durationMinutes: 0,
        createdAt: now,
      ),
    );

    // Centang langsung
    final success = await questDao.completeQuest(questId);
    expect(success, isTrue);

    // Cek quest bertanda is_completed = 1
    final q = await questDao.getQuestById(questId);
    expect(q!.isCompleted, isTrue);

    // Cek quest_history bertambah 1
    final history = await questDao.getQuestHistory();
    expect(history.length, equals(1));
    expect(history.first.title, equals('Minum Air Putih'));
    expect(history.first.xpEarned, equals(15));
    expect(history.first.coinEarned, equals(10));

    // Cek hero_profile koin bertambah (+10 dari koin awal 50 = 60)
    final hero = await heroDao.getHeroProfile();
    expect(hero.coins, equals(60));
    expect(hero.xp, equals(15));
  });

  test('Alur Quest Ber-Timer: Bonus +20% XP Selesai Tepat Waktu & Menit Fokus', () async {
    final now = DateTime.now().toIso8601String();

    // Insert Quest Ber-Timer (Normal)
    final questId = await questDao.insertQuest(
      Quest(
        title: 'Belajar Coding Flutter',
        category: 'daily',
        difficulty: 'normal',
        xpReward: 50,
        coinReward: 35,
        isTimed: true,
        durationMinutes: 25,
        createdAt: now,
      ),
    );

    // Selesaikan dengan timer bonus (+20% XP) dan 25 menit fokus
    final success = await questDao.completeQuest(
      questId,
      focusMinutes: 25,
      hasTimerBonus: true,
    );
    expect(success, isTrue);

    // History mencatat focus_minutes = 25
    final history = await questDao.getQuestHistory();
    expect(history.first.focusMinutes, equals(25));

    // Cek Hero XP: 50 XP + 20% bonus = 60 XP
    final hero = await heroDao.getHeroProfile();
    expect(hero.xp, equals(60));
    expect(hero.coins, equals(85)); // 50 awal + 35 = 85
  });

  test('Alur Level Up Loop & Target XP naik 25%', () async {
    // Hero awal: Lv.1, XP 0, xpNext 100
    // Berikan 120 XP -> harus naik ke Lv.2 dengan sisa 20 XP dan xpNext 125
    final heroAfterLevelUp = await heroDao.addXpAndCoins(120, 50);
    expect(heroAfterLevelUp.level, equals(2));
    expect(heroAfterLevelUp.xp, equals(20)); // 120 - 100 = 20
    expect(heroAfterLevelUp.xpNext, equals(125)); // (100 * 1.25).round() = 125
  });

  test('Filter Tab Kategori: Daily, Weekly, Epic, Timed', () async {
    final now = DateTime.now().toIso8601String();

    await questDao.insertQuest(Quest(
      title: 'Quest Daily',
      category: 'daily',
      xpReward: 15,
      coinReward: 10,
      createdAt: now,
    ));

    await questDao.insertQuest(Quest(
      title: 'Quest Weekly',
      category: 'weekly',
      xpReward: 30,
      coinReward: 20,
      createdAt: now,
    ));

    await questDao.insertQuest(Quest(
      title: 'Quest Epic',
      category: 'epic',
      xpReward: 60,
      coinReward: 40,
      createdAt: now,
    ));

    await questDao.insertQuest(Quest(
      title: 'Quest Timed',
      category: 'daily',
      isTimed: true,
      durationMinutes: 25,
      xpReward: 50,
      coinReward: 35,
      createdAt: now,
    ));

    final dailyList = await questDao.getQuests(category: 'daily');
    final weeklyList = await questDao.getQuests(category: 'weekly');
    final epicList = await questDao.getQuests(category: 'epic');
    final timedList = await questDao.getQuests(isTimed: true);

    expect(dailyList.length, equals(2)); // 1 regular daily + 1 timed daily
    expect(weeklyList.length, equals(1));
    expect(epicList.length, equals(1));
    expect(timedList.length, equals(1));
    expect(timedList.first.title, equals('Quest Timed'));
  });
}
