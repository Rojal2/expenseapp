import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeEntry {
  final String id;
  final double amount;
  final DateTime date;
  final String type; // New field for categorization
  final String? description;

  IncomeEntry({
    required this.id,
    required this.amount,
    required this.date,
    required this.type, // Make it a required parameter
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'type': type, // Add the type to the map
    'description': description,
  };

  factory IncomeEntry.fromMap(String id, Map<String, dynamic> map) {
    return IncomeEntry(
      id: id,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? (map['date'] is Timestamp
                ? (map['date'] as Timestamp).toDate()
                : DateTime.parse(map['date']))
          : DateTime.now(),
      type:
          map['type'] as String? ??
          'irregular', // Handle old entries without a type
      description: map['description'] as String?,
    );
  }
}
