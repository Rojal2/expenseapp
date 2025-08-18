// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'budgets_provider.dart';
// import 'budget_detail_screen.dart';

// class BudgetListScreen extends ConsumerWidget {
//   const BudgetListScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final budgetsAsync = ref.watch(budgetsProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('My Budgets')),
//       body: budgetsAsync.when(
//         data: (budgets) {
//           if (budgets.docs.isEmpty)
//             return const Center(child: Text('No budgets found.'));
//           return ListView.builder(
//             itemCount: budgets.docs.length,
//             itemBuilder: (context, index) {
//               final budget = budgets.docs[index];
//               return ListTile(
//                 title: Text(budget['name']),
//                 subtitle: Text('Limit: ₹${budget['limit']}'),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => BudgetDetailScreen(
//                         budgetId: budget.id,
//                         budgetData: budget.data(),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }
// }
