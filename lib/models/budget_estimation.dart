import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double estimatedAmount;
  final int month; // numeric (1-12)
  final int year;

  Budget({
    required this.id,
    required this.category,
    required this.estimatedAmount,
    required this.month,
    required this.year,
  });

  factory Budget.fromMap(String id, Map<String, dynamic> data) {
    return Budget(
      id: id,
      category: data['category'] ?? '',
      estimatedAmount: (data['estimatedAmount'] as num).toDouble(),
      month: data['month'] ?? 1,
      year: data['year'] ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'estimatedAmount': estimatedAmount,
      'month': month,
      'year': year,
    };
  }
}
