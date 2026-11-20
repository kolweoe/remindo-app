class HeroProfile {
  final int id;
  final String name;
  final int level;
  final int xp;
  final int xpNext;
  final int coins;
  final int streakDays;
  final int roomLevel;
  final String activeCostumeId;
  final String activePetId;
  final String? lastActiveDate;

  HeroProfile({
    this.id = 1,
    required this.name,
    this.level = 1,
    this.xp = 0,
    this.xpNext = 100,
    this.coins = 0,
    this.streakDays = 0,
    this.roomLevel = 1,
    this.activeCostumeId = 'hoodie_ungu',
    this.activePetId = 'cat_tuxedo',
    this.lastActiveDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
      'xp_next': xpNext,
      'coins': coins,
      'streak_days': streakDays,
      'room_level': roomLevel,
      'active_costume_id': activeCostumeId,
      'active_pet_id': activePetId,
      'last_active_date': lastActiveDate,
    };
  }

  factory HeroProfile.fromMap(Map<String, dynamic> map) {
    return HeroProfile(
      id: map['id'] as int? ?? 1,
      name: map['name'] as String? ?? 'Hero Remindo',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      xpNext: map['xp_next'] as int? ?? 100,
      coins: map['coins'] as int? ?? 0,
      streakDays: map['streak_days'] as int? ?? 0,
      roomLevel: map['room_level'] as int? ?? 1,
      activeCostumeId: map['active_costume_id'] as String? ?? 'hoodie_ungu',
      activePetId: map['active_pet_id'] as String? ?? 'cat_tuxedo',
      lastActiveDate: map['last_active_date'] as String?,
    );
  }

  HeroProfile copyWith({
    int? id,
    String? name,
    int? level,
    int? xp,
    int? xpNext,
    int? coins,
    int? streakDays,
    int? roomLevel,
    String? activeCostumeId,
    String? activePetId,
    String? lastActiveDate,
  }) {
    return HeroProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpNext: xpNext ?? this.xpNext,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      roomLevel: roomLevel ?? this.roomLevel,
      activeCostumeId: activeCostumeId ?? this.activeCostumeId,
      activePetId: activePetId ?? this.activePetId,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
