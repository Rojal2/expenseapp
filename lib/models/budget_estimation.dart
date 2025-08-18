import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double estimatedAmount;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.category,
    required this.estimatedAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'estimatedAmount': estimatedAmount,
    'month': month,
    'year': year,
  };

  factory Budget.fromMap(String id, Map<String, dynamic> map) {
    return Budget(
      id: id,
      category: map['category'] as String? ?? '',
      estimatedAmount: (map['estimatedAmount'] as num?)?.toDouble() ?? 0.0,
      month: map['month'] as int? ?? 1,
      year: map['year'] as int? ?? DateTime.now().year,
    );
  }
}
