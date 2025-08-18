import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Convert Expense to Firestore map
  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'note': note,
    'date': Timestamp.fromDate(date), // store as Timestamp
    'description': description,
  };

  /// Create Expense from Firestore map
  static Expense fromMap(String id, Map<String, dynamic> map) => Expense(
    id: id,
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    category: map['category'] as String? ?? '',
    note: map['note'] as String? ?? '',
    date: map['date'] != null
        ? (map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.parse(map['date']))
        : DateTime.now(),
    description: map['description'] as String? ?? '',
  );
}
