class IncomeEntry {
  final String id;
  final double amount;
  final DateTime date;
  final String? description;

  IncomeEntry({
    required this.id,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory IncomeEntry.fromMap(String id, Map<String, dynamic> map) {
    return IncomeEntry(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}
