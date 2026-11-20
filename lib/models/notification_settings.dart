import 'dart:convert';

class NotificationSettings {
  final int id;
  final bool isEnabled;
  final String displayMode; // 'home' | 'lock' | 'auto'
  final bool dailyEnabled;
  final List<String> dailyDays; // e.g. ["Sen", "Rab", "Jum"]
  final String dailyTime; // e.g. '20:00'
  final bool monthlyEnabled;
  final String monthlyDay; // '1' | '15' | '25' | 'last'
  final String monthlyTime; // e.g. '09:00'
  final String title;
  final String message;
  final bool includeIncome;
  final bool includeExpense;
  final bool includeBalance;

  NotificationSettings({
    this.id = 1,
    this.isEnabled = true,
    this.displayMode = 'auto',
    this.dailyEnabled = true,
    this.dailyDays = const ['Sen', 'Rab', 'Jum'],
    this.dailyTime = '20:00',
    this.monthlyEnabled = true,
    this.monthlyDay = 'last',
    this.monthlyTime = '09:00',
    this.title = 'Laporan Dompetku',
    this.message = 'Cek ringkasan uang jajanmu hari ini!',
    this.includeIncome = true,
    this.includeExpense = true,
    this.includeBalance = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_enabled': isEnabled ? 1 : 0,
      'display_mode': displayMode,
      'daily_enabled': dailyEnabled ? 1 : 0,
      'daily_days': jsonEncode(dailyDays),
      'daily_time': dailyTime,
      'monthly_enabled': monthlyEnabled ? 1 : 0,
      'monthly_day': monthlyDay,
      'monthly_time': monthlyTime,
      'title': title,
      'message': message,
      'include_income': includeIncome ? 1 : 0,
      'include_expense': includeExpense ? 1 : 0,
      'include_balance': includeBalance ? 1 : 0,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    List<String> parsedDays = ['Sen', 'Rab', 'Jum'];
    if (map['daily_days'] != null) {
      try {
        final decoded = jsonDecode(map['daily_days'] as String);
        if (decoded is List) {
          parsedDays = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return NotificationSettings(
      id: map['id'] as int? ?? 1,
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
      displayMode: map['display_mode'] as String? ?? 'auto',
      dailyEnabled: (map['daily_enabled'] as int? ?? 1) == 1,
      dailyDays: parsedDays,
      dailyTime: map['daily_time'] as String? ?? '20:00',
      monthlyEnabled: (map['monthly_enabled'] as int? ?? 1) == 1,
      monthlyDay: map['monthly_day'] as String? ?? 'last',
      monthlyTime: map['monthly_time'] as String? ?? '09:00',
      title: map['title'] as String? ?? 'Laporan Dompetku',
      message: map['message'] as String? ?? 'Cek ringkasan uang jajanmu hari ini!',
      includeIncome: (map['include_income'] as int? ?? 1) == 1,
      includeExpense: (map['include_expense'] as int? ?? 1) == 1,
      includeBalance: (map['include_balance'] as int? ?? 1) == 1,
    );
  }

  NotificationSettings copyWith({
    int? id,
    bool? isEnabled,
    String? displayMode,
    bool? dailyEnabled,
    List<String>? dailyDays,
    String? dailyTime,
    bool? monthlyEnabled,
    String? monthlyDay,
    String? monthlyTime,
    String? title,
    String? message,
    bool? includeIncome,
    bool? includeExpense,
    bool? includeBalance,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      isEnabled: isEnabled ?? this.isEnabled,
      displayMode: displayMode ?? this.displayMode,
      dailyEnabled: dailyEnabled ?? this.dailyEnabled,
      dailyDays: dailyDays ?? this.dailyDays,
      dailyTime: dailyTime ?? this.dailyTime,
      monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
      monthlyDay: monthlyDay ?? this.monthlyDay,
      monthlyTime: monthlyTime ?? this.monthlyTime,
      title: title ?? this.title,
      message: message ?? this.message,
      includeIncome: includeIncome ?? this.includeIncome,
      includeExpense: includeExpense ?? this.includeExpense,
      includeBalance: includeBalance ?? this.includeBalance,
    );
  }
}
