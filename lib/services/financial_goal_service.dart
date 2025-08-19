import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_goal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinancialGoalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<FinancialGoal?> getGoalForMonth(int month, int year) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('financial_goals')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return FinancialGoal.fromFirestore(snapshot.docs.first);
        });
  }

  Future<void> setFinancialGoal(FinancialGoal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('financial_goals');

    final query = await collectionRef
        .where('month', isEqualTo: goal.month)
        .where('year', isEqualTo: goal.year)
        .get();

    if (query.docs.isEmpty) {
      await collectionRef.add(goal.toMap());
    } else {
      await collectionRef.doc(query.docs.first.id).update(goal.toMap());
    }
  }

  Future<void> deleteFinancialGoal(FinancialGoal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('financial_goals');

    final query = await collectionRef
        .where('month', isEqualTo: goal.month)
        .where('year', isEqualTo: goal.year)
        .get();

    if (query.docs.isNotEmpty) {
      await collectionRef.doc(query.docs.first.id).delete();
    }
  }
}
