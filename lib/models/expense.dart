class Expense {
  String id;
  double amount;
  String category;
  String note;
  DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  };

  static Expense fromMap(String id, Map<String, dynamic> map) => Expense(
    id: id,
    amount: (map['amount'] as num).toDouble(),
    category: map['category'],
    note: map['note'],
    date: DateTime.parse(map['date']),
  );
}
