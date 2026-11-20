class SavingsGoal {
  final int? id;
  final String title;
  final int targetAmount;
  final int savedAmount;
  final String createdAt;

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'created_at': createdAt,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: map['target_amount'] as int,
      savedAmount: map['saved_amount'] as int? ?? 0,
      createdAt: map['created_at'] as String,
    );
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final pct = savedAmount / targetAmount;
    return pct.clamp(0.0, 1.0);
  }
}
