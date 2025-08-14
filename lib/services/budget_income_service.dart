import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';

class BudgetIncomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _budgetsCollection = 'budgets';
  final String _incomesCollection = 'incomes';

  // Budget operations
  Future<void> saveBudget(Budget budget) async {
    try {
      await _firestore
          .collection(_budgetsCollection)
          .doc(budget.year.toString())
          .set(budget.toMap());
    } catch (e) {
      throw Exception('Failed to save budget: $e');
    }
  }

  Future<Budget?> getBudgetByYear(int year) async {
    try {
      final doc = await _firestore
          .collection(_budgetsCollection)
          .doc(year.toString())
          .get();

      if (doc.exists && doc.data() != null) {
        return Budget.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get budget: $e');
    }
  }

  Future<Budget?> getCurrentBudget() async {
    final currentYear = DateTime.now().year;
    return await getBudgetByYear(currentYear);
  }

  Future<List<Budget>> getAllBudgets() async {
    try {
      final querySnapshot = await _firestore
          .collection(_budgetsCollection)
          .orderBy('year', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Budget.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get budgets: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _firestore
          .collection(_budgetsCollection)
          .doc(budget.year.toString())
          .update(budget.toMap());
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  Future<void> deleteBudget(int year) async {
    try {
      await _firestore
          .collection(_budgetsCollection)
          .doc(year.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  Future<void> updateMonthlyBudget(
    int year,
    String month,
    double amount,
  ) async {
    try {
      final budget = await getBudgetByYear(year);
      if (budget != null) {
        final updatedMonthlyBudgets = Map<String, double>.from(
          budget.monthlyBudgets,
        );
        updatedMonthlyBudgets[month] = amount;

        final updatedBudget = budget.copyWith(
          monthlyBudgets: updatedMonthlyBudgets,
        );
        await updateBudget(updatedBudget);
      } else {
        final newBudget = Budget(
          year: year,
          yearlyBudget: 0.0,
          monthlyBudgets: {month: amount},
        );
        await saveBudget(newBudget);
      }
    } catch (e) {
      throw Exception('Failed to update monthly budget: $e');
    }
  }

  // Income operations
  Future<void> saveIncome(Map<String, dynamic> incomeData) async {
    try {
      await _firestore.collection(_incomesCollection).add({
        ...incomeData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save income: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getIncomesByYear(int year) async {
    try {
      final querySnapshot = await _firestore
          .collection(_incomesCollection)
          .where('year', isEqualTo: year)
          .orderBy('month')
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      throw Exception('Failed to get incomes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCurrentYearIncomes() async {
    final currentYear = DateTime.now().year;
    return await getIncomesByYear(currentYear);
  }

  Future<double> getTotalIncomeByYear(int year) async {
    try {
      final incomes = await getIncomesByYear(year);
      return incomes.fold<double>(
        0.0,
        (total, income) => total + (income['amount']?.toDouble() ?? 0.0),
      );
    } catch (e) {
      throw Exception('Failed to calculate total income: $e');
    }
  }

  Future<double> getMonthlyIncome(int year, int month) async {
    try {
      final querySnapshot = await _firestore
          .collection(_incomesCollection)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();

      return querySnapshot.docs.fold<double>(0.0, (total, doc) {
        final data = doc.data();
        return total + (data['amount']?.toDouble() ?? 0.0);
      });
    } catch (e) {
      throw Exception('Failed to get monthly income: $e');
    }
  }

  Future<void> updateIncome(
    String incomeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(_incomesCollection).doc(incomeId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update income: $e');
    }
  }

  Future<void> deleteIncome(String incomeId) async {
    try {
      await _firestore.collection(_incomesCollection).doc(incomeId).delete();
    } catch (e) {
      throw Exception('Failed to delete income: $e');
    }
  }

  // Utility methods
  String getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  String getCurrentMonthKey() {
    return getMonthKey(DateTime.now());
  }

  // Budget analysis methods
  Future<Map<String, dynamic>> getBudgetAnalysis(int year) async {
    try {
      final budget = await getBudgetByYear(year);
      if (budget == null) {
        return {
          'totalBudget': 0.0,
          'allocatedBudget': 0.0,
          'remainingBudget': 0.0,
          'monthlyBreakdown': <String, double>{},
        };
      }

      final allocatedBudget = budget.totalMonthlyBudgets;
      final remainingBudget = budget.yearlyBudget - allocatedBudget;

      return {
        'totalBudget': budget.yearlyBudget,
        'allocatedBudget': allocatedBudget,
        'remainingBudget': remainingBudget,
        'monthlyBreakdown': budget.monthlyBudgets,
      };
    } catch (e) {
      throw Exception('Failed to analyze budget: $e');
    }
  }

  // Stream methods for real-time updates
  Stream<Budget?> watchBudget(int year) {
    return _firestore
        .collection(_budgetsCollection)
        .doc(year.toString())
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return Budget.fromMap(doc.id, doc.data()!);
          }
          return null;
        });
  }

  Stream<List<Map<String, dynamic>>> watchIncomes(int year) {
    return _firestore
        .collection(_incomesCollection)
        .where('year', isEqualTo: year)
        .orderBy('month')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }
}
