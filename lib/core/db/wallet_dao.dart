import 'database_helper.dart';
import '../../models/transaction.dart';
import '../../models/savings_goal.dart';

class WalletDao {
  final DatabaseHelper dbHelper;

  WalletDao({DatabaseHelper? helper}) : dbHelper = helper ?? DatabaseHelper.instance;

  /// Returns current net balance: SUM(income) - SUM(expense)
  Future<int> getBalance() async {
    final db = await dbHelper.database;
    final incomeResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );

    final totalIncome = (incomeResult.first['total'] as int?) ?? 0;
    final totalExpense = (expenseResult.first['total'] as int?) ?? 0;

    return totalIncome - totalExpense;
  }

  Future<List<TransactionItem>> getTransactions({String? type, int limit = 50}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type] : null,
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }

  Future<int> insertTransaction(TransactionItem item) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', item.toMap());
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await dbHelper.database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await dbHelper.database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deposit into a savings goal within an atomic transaction:
  /// 1. Increments saved_amount in savings_goals
  /// 2. Records an expense of category 'Tabungan' in transactions
  Future<bool> depositToSavings(int goalId, int amount) async {
    if (amount <= 0) return false;
    final db = await dbHelper.database;

    final goals = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [goalId],
      limit: 1,
    );
    if (goals.isEmpty) return false;

    final goal = SavingsGoal.fromMap(goals.first);
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Update savings_goals
      await txn.update(
        'savings_goals',
        {'saved_amount': goal.savedAmount + amount},
        where: 'id = ?',
        whereArgs: [goalId],
      );

      // 2. Insert expense transaction
      await txn.insert('transactions', {
        'type': 'expense',
        'amount': amount,
        'category': 'Tabungan',
        'note': 'Setor ke Peti Tabungan: ${goal.title}',
        'created_at': now,
      });
    });

    return true;
  }

  /// Returns detailed financial report
  Future<Map<String, int>> getFinancialSummary() async {
    final db = await dbHelper.database;

    final incomeResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );
    final savingsResult = await db.rawQuery(
      "SELECT SUM(saved_amount) as total FROM savings_goals",
    );

    final totalIncome = (incomeResult.first['total'] as int?) ?? 0;
    final totalExpense = (expenseResult.first['total'] as int?) ?? 0;
    final totalSavings = (savingsResult.first['total'] as int?) ?? 0;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
      'savings': totalSavings,
    };
  }
}
