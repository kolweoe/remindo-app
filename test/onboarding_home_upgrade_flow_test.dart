import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:remindo_app/core/db/hero_dao.dart';
import 'package:remindo_app/core/db/database_helper.dart';

// Test implementation of DatabaseHelper using in-memory database
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
  // Initialize ffi for running sqlite tests on Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late HeroDao heroDao;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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

          // 2. transactions
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

          // 3. app_settings
          await db.execute('''
            CREATE TABLE app_settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    heroDao = HeroDao(helper: TestDatabaseHelper(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('Alur Onboarding -> Home -> RoomUpgrade Verification', () async {
    // 1. Cek sebelum Onboarding: hero_profile harus kosong
    final hasInitialHero = await heroDao.hasHeroProfile();
    expect(hasInitialHero, isFalse, reason: 'Aplikasi baru harus belum memiliki hero_profile');

    // 2. Eksekusi Onboarding: Mulai Petualangan
    final hero = await heroDao.createInitialHero(
      name: 'Raka Petualang',
      starterAvatar: 'hoodie_ungu',
      focusGoal: 'Kuliah',
    );

    expect(hero.name, equals('Raka Petualang'));
    expect(hero.coins, equals(50), reason: 'Bonus awal Onboarding harus +50 Coin');
    expect(hero.roomLevel, equals(1), reason: 'Kamar awal harus Lv.1');
    expect(hero.level, equals(1));

    // Cek setelah Onboarding: hero_profile sekarang harus true
    final hasHeroAfterOnboarding = await heroDao.hasHeroProfile();
    expect(hasHeroAfterOnboarding, isTrue);

    // 3. Coba Upgrade Kamar ke Lv.2 dengan koin awal 50 (Syarat: 200 Coin & Hero Lv.2)
    final failResult = await heroDao.upgradeRoomTo(2);
    expect(failResult.success, isFalse);
    expect(failResult.message, contains('Hero Lv.2'), reason: 'Harus mengecek syarat Hero Lv.2');

    // 4. Tambahkan XP dan Coin untuk mencapai Hero Lv.2 dan cukup koin
    // Hero butuh 100 XP untuk Lv.2. Tambahkan 150 XP dan 300 Coin.
    final updatedHero = await heroDao.addXpAndCoins(150, 300);
    expect(updatedHero.level, equals(2), reason: 'Hero harus naik ke Lv.2');
    expect(updatedHero.coins, equals(350), reason: 'Koin awal 50 + 300 = 350');

    // 5. Eksekusi Upgrade Kamar ke Lv.2 yang valid
    final successResult = await heroDao.upgradeRoomTo(2);
    expect(successResult.success, isTrue);
    expect(successResult.targetLevel, equals(2));
    expect(successResult.message, contains('berhasil di-upgrade'));

    // 6. Verifikasi state hero setelah upgrade kamar
    final heroAfterUpgrade = await heroDao.getHeroProfile();
    expect(heroAfterUpgrade.roomLevel, equals(2), reason: 'Level kamar sekarang harus Lv.2');
    expect(heroAfterUpgrade.coins, equals(150), reason: 'Koin harus terpotong 200 (350 - 200 = 150)');

    // 7. Verifikasi transaksi tercatat di tabel transactions
    final transactions = await db.query('transactions');
    expect(transactions.length, equals(1));
    expect(transactions.first['amount'], equals(200));
    expect(transactions.first['category'], equals('Upgrade Kamar'));
  });
}
