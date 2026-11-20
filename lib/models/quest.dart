class Quest {
  final int? id;
  final String title;
  final String category; // 'daily' | 'weekly' | 'epic' | 'timed'
  final String difficulty; // 'easy' | 'normal' | 'hard'
  final int xpReward;
  final int coinReward;
  final bool isTimed;
  final int durationMinutes;
  final String? alarmTime; // 'HH:mm' or null
  final String repeatRule; // 'once' | 'daily' | 'weekly'
  final bool isCompleted;
  final String createdAt;

  Quest({
    this.id,
    required this.title,
    required this.category,
    this.difficulty = 'normal',
    required this.xpReward,
    required this.coinReward,
    this.isTimed = false,
    this.durationMinutes = 25,
    this.alarmTime,
    this.repeatRule = 'once',
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'xp_reward': xpReward,
      'coin_reward': coinReward,
      'is_timed': isTimed ? 1 : 0,
      'duration_minutes': durationMinutes,
      'alarm_time': alarmTime,
      'repeat_rule': repeatRule,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      difficulty: map['difficulty'] as String? ?? 'normal',
      xpReward: map['xp_reward'] as int,
      coinReward: map['coin_reward'] as int,
      isTimed: (map['is_timed'] as int? ?? 0) == 1,
      durationMinutes: map['duration_minutes'] as int? ?? 25,
      alarmTime: map['alarm_time'] as String?,
      repeatRule: map['repeat_rule'] as String? ?? 'once',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Quest copyWith({
    int? id,
    String? title,
    String? category,
    String? difficulty,
    int? xpReward,
    int? coinReward,
    bool? isTimed,
    int? durationMinutes,
    String? alarmTime,
    String? repeatRule,
    bool? isCompleted,
    String? createdAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      isTimed: isTimed ?? this.isTimed,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      alarmTime: alarmTime ?? this.alarmTime,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class QuestHistory {
  final int? id;
  final int? questId;
  final String title;
  final String completedAt;
  final int xpEarned;
  final int coinEarned;
  final int focusMinutes;

  QuestHistory({
    this.id,
    this.questId,
    required this.title,
    required this.completedAt,
    required this.xpEarned,
    required this.coinEarned,
    this.focusMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'quest_id': questId,
      'title': title,
      'completed_at': completedAt,
      'xp_earned': xpEarned,
      'coin_earned': coinEarned,
      'focus_minutes': focusMinutes,
    };
  }

  factory QuestHistory.fromMap(Map<String, dynamic> map) {
    return QuestHistory(
      id: map['id'] as int?,
      questId: map['quest_id'] as int?,
      title: map['title'] as String,
      completedAt: map['completed_at'] as String,
      xpEarned: map['xp_earned'] as int,
      coinEarned: map['coin_earned'] as int,
      focusMinutes: map['focus_minutes'] as int? ?? 0,
    );
  }
}
