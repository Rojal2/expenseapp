import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_estimation.dart';

class BudgetService {
  final _db = FirebaseFirestore.instance;

  // Get budgets for a specific month
  Stream<List<Budget>> getBudgetsForMonth(int month, int year) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Budget.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Add or Update Budget
  Future<void> addOrUpdateBudget(Budget budget) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check for duplicate category in the same month/year
    final duplicateQuery = await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .where('month', isEqualTo: budget.month)
        .where('year', isEqualTo: budget.year)
        .where('category', isEqualTo: budget.category)
        .get();

    if (duplicateQuery.docs.isNotEmpty && budget.id.isEmpty) {
      throw Exception('Category already exists for this month');
    }

    if (budget.id.isEmpty) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .add(budget.toMap());
    } else {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap());
    }
  }

  // Delete Budget
  Future<void> deleteBudget(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(id)
        .delete();
  }
}
