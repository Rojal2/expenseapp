import 'package:expenseapp/screens/analytics/analytics_dashboard.dart';
import 'package:expenseapp/screens/list_budget.dart';
import 'package:expenseapp/screens/list_expense.dart';
import 'package:expenseapp/screens/list_income.dart';
import 'package:expenseapp/screens/profile_screen.dart';
import 'package:expenseapp/services/financial_goal_service.dart';
import 'package:expenseapp/widgets/financial_goal.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_goal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  User? getCurrentUser() => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final financialGoalService = FinancialGoalService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Budget Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Budget Tracker",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Your financial assistant",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              "Expenses",
              Icons.money,
              const ListExpenseScreen(),
            ),
            _buildDrawerItem(
              context,
              "Income",
              Icons.account_balance_wallet,
              const IncomeListScreen(),
            ),
            _buildDrawerItem(
              context,
              "Budget",
              Icons.account_balance_wallet,
              const BudgetScreen(),
            ),
            _buildDrawerItem(
              context,
              "Analytics",
              Icons.bar_chart,
              const AnalyticsDashboard(),
            ),
            _buildDrawerItem(
              context,
              "Profile",
              Icons.person,
              const ProfileScreen(),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Welcome to Budget Tracker",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Budget Tracker helps you manage your income, track expenses, "
                "and set financial goals for each month. Stay on top of your finances "
                "and achieve your savings targets effortlessly.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            // Financial Goal Widget for current month
            FinancialGoalWidget(financialGoalService: financialGoalService),

            const SizedBox(height: 24),

            // Button to view all goals for current year
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month, size: 20),
                label: const Text("View All Goals for This Year"),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('financial_goals')
                      .where('year', isEqualTo: currentYear)
                      .orderBy('month')
                      .get();

                  final goals = snapshot.docs
                      .map((doc) => FinancialGoal.fromFirestore(doc))
                      .toList();

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        "Financial Goals - $currentYear",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: goals.isEmpty
                            ? const Center(
                                child: Text(
                                  "No financial goals set for this year.",
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: goals.length,
                                itemBuilder: (context, index) {
                                  final g = goals[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat.MMMM().format(
                                              DateTime(g.year, g.month),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _buildGoalText(
                                            "Income",
                                            g.incomeGoal,
                                            Colors.green,
                                          ),
                                          _buildGoalText(
                                            "Expense",
                                            g.expenseGoal,
                                            Colors.red,
                                          ),
                                          _buildGoalText(
                                            "Saving",
                                            g.savingGoal,
                                            Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.teal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  // The helper function is now defined here, but you were calling it from
  // another BuildContext.
  // The correct fix is to copy-paste this function inside the
  // `showDialog`'s builder.
  Widget _buildGoalText(String label, double amount, Color color) {
    return Text(
      "$label: ₹${amount.toStringAsFixed(2)}",
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
    );
  }
}
