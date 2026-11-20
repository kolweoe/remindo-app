import 'database_helper.dart';
import 'hero_dao.dart';
import '../../models/quest.dart';

class QuestDao {
  final DatabaseHelper dbHelper;
  final HeroDao heroDao;

  QuestDao({DatabaseHelper? helper, HeroDao? hero})
      : dbHelper = helper ?? DatabaseHelper.instance,
        heroDao = hero ?? HeroDao();

  Future<List<Quest>> getQuests({String? category, bool? isCompleted}) async {
    final db = await dbHelper.database;
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (category != null && isCompleted != null) {
      whereClause = 'category = ? AND is_completed = ?';
      whereArgs = [category, isCompleted ? 1 : 0];
    } else if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    } else if (isCompleted != null) {
      whereClause = 'is_completed = ?';
      whereArgs = [isCompleted ? 1 : 0];
    }

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

  Future<List<QuestHistory>> getQuestHistory({int limit = 50}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quest_history',
      orderBy: 'id DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => QuestHistory.fromMap(maps[i]));
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
