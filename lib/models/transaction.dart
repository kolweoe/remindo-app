class TransactionItem {
  final int? id;
  final String type; // 'income' | 'expense'
  final int amount;
  final String category;
  final String? note;
  final String createdAt;

  TransactionItem({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
