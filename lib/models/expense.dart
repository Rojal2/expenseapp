class Expense {
  String id;
  double amount;
  String category;
  String note;
  DateTime date;
  String description;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'description': description,
  };

  static Expense fromMap(String id, Map<String, dynamic> map) => Expense(
    id: id,
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    category: map['category'] as String? ?? '',
    note: map['note'] as String? ?? '',
    date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    description: map['description'] as String? ?? '',
  );
}
