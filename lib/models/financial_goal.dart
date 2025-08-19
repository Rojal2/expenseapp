import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialGoal {
  final String id;
  final double incomeGoal;
  final double expenseGoal;
  final double savingGoal;
  final int month;
  final int year;

  FinancialGoal({
    required this.id,
    required this.incomeGoal,
    required this.expenseGoal,
    required this.savingGoal,
    required this.month,
    required this.year,
  });

  factory FinancialGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialGoal(
      id: doc.id,
      incomeGoal: (data['incomeGoal'] ?? 0).toDouble(),
      expenseGoal: (data['expenseGoal'] ?? 0).toDouble(),
      savingGoal: (data['savingGoal'] ?? 0).toDouble(),
      month: data['month'] ?? DateTime.now().month,
      year: data['year'] ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'incomeGoal': incomeGoal,
      'expenseGoal': expenseGoal,
      'savingGoal': savingGoal,
      'month': month,
      'year': year,
    };
  }
}
