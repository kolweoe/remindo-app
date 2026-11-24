import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/hero_profile.dart';

class UpgradeRoomResult {
  final bool success;
  final String message;
  final int targetLevel;
  final int requiredCoins;
  final int requiredHeroLevel;

  UpgradeRoomResult({
    required this.success,
    required this.message,
    required this.targetLevel,
    this.requiredCoins = 0,
    this.requiredHeroLevel = 1,
  });
}

class HeroDao {
  final DatabaseHelper dbHelper;

  HeroDao({DatabaseHelper? helper}) : dbHelper = helper ?? DatabaseHelper.instance;

  static const Map<int, int> roomUpgradeCosts = {
    2: 200,
    3: 400,
    4: 700,
    5: 1100,
    6: 1600,
    7: 2200,
    8: 3000,
  };

  static const Map<int, int> roomRequiredHeroLevels = {
    2: 2,
    3: 3,
    4: 4,
    5: 5,
    6: 6,
    7: 7,
    8: 8,
  };

  static const Map<int, String> roomNames = {
    1: 'Kamar Awal',
    2: 'Kasur Nyaman',
    3: 'Meja Belajar',
    4: 'Lemari & Rak',
    5: 'Karpet Mewah',
    6: 'Perpustakaan Mini',
    7: 'Studio Musik',
    8: 'Kamar Impian MAX',
  };

  static const Map<int, String> roomDescriptions = {
    1: 'Kasur lantai sederhana, jendela senja, karakter hero ungu, dan kucing peliharaan.',
    2: 'Dipan kayu kokoh dengan kasur busa empuk, seprai ungu, dan lampu tidur kelinci.',
    3: 'Meja belajar kayu pinus, kursi ergonomis, laptop retro, dan rak catatan.',
    4: 'Lemari pakaian 2 pintu, rak buku dinding, dan gantungan tas petualang.',
    5: 'Karpet bulu tebal motif pixel art, bantal duduk santai, dan tanaman sukulen.',
    6: 'Lampu gantung peri hangat, lemari buku penuh, dan karpet wajah kucing.',
    7: 'Akuarium ikan hias, gitar akustik, amplifier, dan trofi prestasi.',
    8: 'Ranjang tingkat loft, setup dual-monitor ungu, lampu peri, dan trofi MAX!',
  };

  static Map<String, int> calculateQuestReward({
    required String difficulty,
    required bool isTimed,
  }) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return isTimed
            ? {'xp': 25, 'coins': 15}
            : {'xp': 15, 'coins': 10};
      case 'hard':
        return isTimed
            ? {'xp': 100, 'coins': 70}
            : {'xp': 60, 'coins': 40};
      case 'normal':
      default:
        return isTimed
            ? {'xp': 50, 'coins': 35}
            : {'xp': 30, 'coins': 20};
    }
  }

  /// Checks whether a valid hero profile already exists in SQLite
  Future<bool> hasHeroProfile() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hero_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Returns HeroProfile or null if none exists yet
  Future<HeroProfile?> getHeroProfileOrNull() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hero_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HeroProfile.fromMap(maps.first);
    }
    return null;
  }

  /// Returns HeroProfile or creates a default if none exists
  Future<HeroProfile> getHeroProfile() async {
    final profile = await getHeroProfileOrNull();
    if (profile != null) return profile;

    // Fallback if missing
    final defaultHero = HeroProfile(name: 'Hero Remindo', coins: 50);
    final db = await dbHelper.database;
    await db.insert('hero_profile', defaultHero.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return defaultHero;
  }

  /// Initial Hero Creation from Onboarding
  Future<HeroProfile> createInitialHero({
    required String name,
    required String starterAvatar,
    required String focusGoal,
  }) async {
    final db = await dbHelper.database;
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    final hero = HeroProfile(
      id: 1,
      name: name.trim().isEmpty ? 'Raka' : name.trim(),
      level: 1,
      xp: 0,
      xpNext: 100,
      coins: 50, // Starter bonus from Penpot (+50 Coin)
      streakDays: 1,
      roomLevel: 1,
      activeCostumeId: starterAvatar.contains('cat') ? 'cat_tuxedo' : 'hoodie_ungu',
      activePetId: 'cat_tuxedo',
      lastActiveDate: todayStr,
    );

    await db.transaction((txn) async {
      await txn.insert(
        'hero_profile',
        hero.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_settings',
        {'key': 'hero_focus_goal', 'value': focusGoal},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_settings',
        {'key': 'onboarding_completed', 'value': 'true'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    return hero;
  }

  Future<int> updateHeroProfile(HeroProfile hero) async {
    final db = await dbHelper.database;
    return await db.update(
      'hero_profile',
      hero.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// Adds XP and Coins, applies streak logic, and executes level-up loop.
  Future<HeroProfile> addXpAndCoins(
    int rawXp,
    int rawCoins, {
    bool hasTimerBonus = false,
  }) async {
    final db = await dbHelper.database;
    final hero = await getHeroProfile();

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    int streak = hero.streakDays;

    if (hero.lastActiveDate == null) {
      streak = 1;
    } else if (hero.lastActiveDate != todayStr) {
      final lastDate = DateTime.tryParse(hero.lastActiveDate!) ?? DateTime.now();
      final diff = DateTime.now().difference(lastDate).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    // Calculate XP bonuses: Streak >= 3 (+20%), Timer Bonus (+20%)
    int xpBonusPercent = 0;
    if (streak >= 3) xpBonusPercent += 20;
    if (hasTimerBonus) xpBonusPercent += 20;

    int xpToAdd = (rawXp * (100 + xpBonusPercent) / 100).round();

    int currentXp = hero.xp + xpToAdd;
    int currentCoins = hero.coins + rawCoins;
    int currentLevel = hero.level;
    int currentXpNext = hero.xpNext;

    // Level up calculation loop
    while (currentXp >= currentXpNext) {
      currentXp -= currentXpNext;
      currentLevel += 1;
      currentXpNext = (currentXpNext * 1.25).round();
    }

    final updated = hero.copyWith(
      level: currentLevel,
      xp: currentXp,
      xpNext: currentXpNext,
      coins: currentCoins,
      streakDays: streak,
      lastActiveDate: todayStr,
    );

    await db.update(
      'hero_profile',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );

    return updated;
  }

  /// Upgrade Room to specified level or next level with validation
  Future<UpgradeRoomResult> upgradeRoomTo(int targetLevel) async {
    final db = await dbHelper.database;
    final hero = await getHeroProfile();

    if (hero.roomLevel >= 8) {
      return UpgradeRoomResult(
        success: false,
        message: 'Kamar sudah mencapai Level Maksimal (Lv.8 MAX)!',
        targetLevel: 8,
      );
    }

    if (targetLevel <= hero.roomLevel) {
      return UpgradeRoomResult(
        success: false,
        message: 'Kamar Lv.$targetLevel sudah aktif!',
        targetLevel: targetLevel,
      );
    }

    final cost = roomUpgradeCosts[targetLevel] ?? 200;
    final reqLevel = roomRequiredHeroLevels[targetLevel] ?? 2;

    // Check Hero Level Requirement
    if (hero.level < reqLevel) {
      return UpgradeRoomResult(
        success: false,
        message: 'Syarat belum terpenuhi: Butuh Hero Lv.$reqLevel (Levelmu saat ini Lv.${hero.level})!',
        targetLevel: targetLevel,
        requiredCoins: cost,
        requiredHeroLevel: reqLevel,
      );
    }

    // Check Coin Requirement
    if (hero.coins < cost) {
      final deficit = cost - hero.coins;
      return UpgradeRoomResult(
        success: false,
        message: 'Koinmu ${hero.coins} — butuh $deficit Coin lagi & Hero Lv.$reqLevel untuk membuka Lv.$targetLevel!',
        targetLevel: targetLevel,
        requiredCoins: cost,
        requiredHeroLevel: reqLevel,
      );
    }

    // Atomic SQLite transaction
    await db.transaction((txn) async {
      // Deduct coins & update room_level
      await txn.update(
        'hero_profile',
        {
          'coins': hero.coins - cost,
          'room_level': targetLevel,
        },
        where: 'id = ?',
        whereArgs: [1],
      );

      // Record transaction history
      await txn.insert('transactions', {
        'type': 'expense',
        'amount': cost,
        'category': 'Upgrade Kamar',
        'note': 'Upgrade kamar ke Lv.$targetLevel (${roomNames[targetLevel]})',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    return UpgradeRoomResult(
      success: true,
      message: 'Selamat! Kamarmu berhasil di-upgrade ke Lv.$targetLevel (${roomNames[targetLevel]})!',
      targetLevel: targetLevel,
      requiredCoins: cost,
      requiredHeroLevel: reqLevel,
    );
  }

  /// Upgrade to next level shorthand
  Future<UpgradeRoomResult> upgradeRoomNext() async {
    final hero = await getHeroProfile();
    return await upgradeRoomTo(hero.roomLevel + 1);
  }

  Future<void> updateActiveCostume(String costumeId) async {
    final db = await dbHelper.database;
    await db.update(
      'hero_profile',
      {'active_costume_id': costumeId},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> updateActivePet(String petId) async {
    final db = await dbHelper.database;
    await db.update(
      'hero_profile',
      {'active_pet_id': petId},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
