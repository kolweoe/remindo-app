import 'database_helper.dart';
import 'hero_dao.dart';
import '../../models/quest.dart';

class QuestDao {
  final DatabaseHelper dbHelper;
  final HeroDao heroDao;

  QuestDao({DatabaseHelper? helper, HeroDao? hero})
      : dbHelper = helper ?? DatabaseHelper.instance,
        heroDao = hero ?? HeroDao();

  Future<List<Quest>> getQuests({
    String? category,
    bool? isCompleted,
    bool? isTimed,
  }) async {
    final db = await dbHelper.database;
    List<String> conditions = [];
    List<dynamic> whereArgs = [];

    if (category != null) {
      conditions.add('LOWER(category) = ?');
      whereArgs.add(category.toLowerCase());
    }
    if (isCompleted != null) {
      conditions.add('is_completed = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }
    if (isTimed != null) {
      conditions.add('is_timed = ?');
      whereArgs.add(isTimed ? 1 : 0);
    }

    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'quests',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_completed ASC, id DESC',
    );

    return List.generate(maps.length, (i) => Quest.fromMap(maps[i]));
  }

  Future<Quest?> getQuestById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quests',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Quest.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertQuest(Quest quest) async {
    final db = await dbHelper.database;
    return await db.insert('quests', quest.toMap());
  }

  Future<int> updateQuest(Quest quest) async {
    final db = await dbHelper.database;
    return await db.update(
      'quests',
      quest.toMap(),
      where: 'id = ?',
      whereArgs: [quest.id],
    );
  }

  Future<int> deleteQuest(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'quests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Completes a quest, awards XP & Coins via HeroDao, and writes to quest_history in a transaction.
  Future<bool> completeQuest(
    int questId, {
    int focusMinutes = 0,
    bool hasTimerBonus = false,
  }) async {
    final db = await dbHelper.database;
    final quest = await getQuestById(questId);
    if (quest == null || quest.isCompleted) return false;

    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Mark quest completed
      await txn.update(
        'quests',
        {'is_completed': 1},
        where: 'id = ?',
        whereArgs: [questId],
      );

      // 2. Insert into history
      await txn.insert('quest_history', {
        'quest_id': questId,
        'title': quest.title,
        'completed_at': now,
        'xp_earned': quest.xpReward,
        'coin_earned': quest.coinReward,
        'focus_minutes': focusMinutes,
      });
    });

    // 3. Award XP and coins to hero (with streak & timer bonus logic)
    await heroDao.addXpAndCoins(
      quest.xpReward,
      quest.coinReward,
      hasTimerBonus: hasTimerBonus,
    );

    return true;
  }

  Future<List<QuestHistory>> getQuestHistory({int limit = 50, String filter = 'Semua'}) async {
    final db = await dbHelper.database;
    String? whereClause;

    if (filter == 'Hari Ini') {
      whereClause = "date(completed_at) = date('now', 'localtime')";
    } else if (filter == 'Minggu Ini') {
      whereClause = "date(completed_at) >= date('now', 'localtime', '-7 days')";
    } else if (filter == 'Bulan Ini') {
      whereClause = "date(completed_at) >= date('now', 'localtime', 'start of month')";
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'quest_history',
      where: whereClause,
      orderBy: 'id DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => QuestHistory.fromMap(maps[i]));
  }

  /// Calculates aggregate statistics for QuestHistory screen
  Future<Map<String, dynamic>> getHistoryStats() async {
    final db = await dbHelper.database;

    final countResult = await db.rawQuery('SELECT COUNT(*) as total, SUM(coin_earned) as total_coins, SUM(focus_minutes) as total_focus FROM quest_history');
    final totalCompleted = (countResult.first['total'] as int?) ?? 0;
    final totalCoins = (countResult.first['total_coins'] as int?) ?? 0;
    final totalFocus = (countResult.first['total_focus'] as int?) ?? 0;

    return {
      'total_completed': totalCompleted,
      'total_coins': totalCoins,
      'total_focus_minutes': totalFocus,
    };
  }

  /// Resets daily recurring quests to uncompleted state
  Future<void> resetDailyQuests() async {
    final db = await dbHelper.database;
    await db.update(
      'quests',
      {'is_completed': 0},
      where: 'repeat_rule = ?',
      whereArgs: ['daily'],
    );
  }
}
