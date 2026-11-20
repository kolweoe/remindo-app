import 'database_helper.dart';
import '../../models/hero_profile.dart';

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

  Future<HeroProfile> getHeroProfile() async {
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

    // Fallback if missing
    final defaultHero = HeroProfile(name: 'Hero Remindo');
    await db.insert('hero_profile', defaultHero.toMap());
    return defaultHero;
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

    // 20% XP Bonus condition: streak >= 3 or timer bonus
    int xpToAdd = rawXp;
    if (streak >= 3 || hasTimerBonus) {
      xpToAdd = (rawXp * 1.20).round();
    }

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

  /// Upgrade Room Level (Lv.1 to Lv.8)
  Future<bool> upgradeRoom() async {
    final db = await dbHelper.database;
    final hero = await getHeroProfile();

    if (hero.roomLevel >= 8) return false;

    final nextLevel = hero.roomLevel + 1;
    final cost = roomUpgradeCosts[nextLevel] ?? 200;

    if (hero.coins < cost) return false;

    final updated = hero.copyWith(
      coins: hero.coins - cost,
      roomLevel: nextLevel,
    );

    await db.update(
      'hero_profile',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );

    return true;
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
