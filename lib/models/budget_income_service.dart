import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'income_entry.dart';
import 'budget.dart';

class BudgetIncomeService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Income methods
  Future<void> addIncome(IncomeEntry entry) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('income')
        .add(entry.toMap());
  }

  Future<void> updateIncome(IncomeEntry entry) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('income')
        .doc(entry.id)
        .update(entry.toMap());
  }

  Future<void> deleteIncome(String id) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('income')
        .doc(id)
        .delete();
  }

  Future<List<IncomeEntry>> fetchIncomeEntries() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('income')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => IncomeEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Budget methods
  Future<void> setBudget(Budget budget) async {
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .doc(budget.year.toString());
    await docRef.set(budget.toMap());
  }

  Future<Budget?> fetchBudget(String year) async {
    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .doc(year)
        .get();
    if (doc.exists) {
      return Budget.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
