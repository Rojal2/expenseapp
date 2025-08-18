// import 'package:flutter/material.dart';
// import '../../models/budget_income_service.dart';
// import '../../models/income_entry.dart';
// import '../../models/budget.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:logger/logger.dart';

// class BudgetIncomeScreen extends StatefulWidget {
//   const BudgetIncomeScreen({super.key});

//   @override
//   State<BudgetIncomeScreen> createState() => _BudgetIncomeScreenState();
// }

// class _BudgetIncomeScreenState extends State<BudgetIncomeScreen> {
//   final _service = BudgetIncomeService();
//   final _incomeAmountController = TextEditingController();
//   final _incomeDescController = TextEditingController();
//   DateTime _incomeDate = DateTime.now();
//   List<IncomeEntry> _incomeEntries = [];
//   bool _loading = false;
//   String? _budgetYear;
//   final _budgetController = TextEditingController();
//   Budget? _budget;
//   int _avgMonths = 6;
//   final logger = Logger();
//   final List<int> _monthOptions = [3, 6, 12];
//   final List<String> _months = const [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];
//   final Map<String, TextEditingController> _monthlyControllers = {};
//   IncomeEntry? _editingIncome;
//   Map<String, double> _monthlyExpenses = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchIncome();
//     _fetchBudget();
//     _fetchMonthlyExpenses();
//     for (var i = 1; i <= 12; i++) {
//       final key = i.toString().padLeft(2, '0');
//       _monthlyControllers[key] = TextEditingController();
//     }
//   }

//   @override
//   void dispose() {
//     _incomeAmountController.dispose();
//     _incomeDescController.dispose();
//     _budgetController.dispose();
//     for (final c in _monthlyControllers.values) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _fetchIncome() async {
//     setState(() => _loading = true);
//     try {
//       final entries = await _service.fetchIncomeEntries();
//       setState(() {
//         _incomeEntries = entries;
//       });
//       logger.i('Fetched income entries: Rs_incomeEntries');
//     } catch (e) {
//       _showSnackbar('Failed to fetch income: $e', color: Colors.white10);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _fetchBudget() async {
//     setState(() => _loading = true);
//     try {
//       final year = DateTime.now().year.toString();
//       final budget = await _service.fetchBudget(year);
//       setState(() {
//         _budgetYear = year;
//         _budget = budget;
//         _budgetController.text = budget?.yearlyBudget.toString() ?? '';
//         if (budget != null) {
//           for (var i = 1; i <= 12; i++) {
//             final key = i.toString().padLeft(2, '0');
//             _monthlyControllers[key]?.text =
//                 budget.monthlyBudgets[key]?.toString() ?? '';
//           }
//         }
//       });
//     } catch (e) {
//       _showSnackbar('Failed to fetch budget: $e', color: Colors.red);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _fetchMonthlyExpenses() async {
//     setState(() => _loading = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//       final year = DateTime.now().year;
//       final expensesRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('expenses');
//       Map<String, double> monthlyTotals = {};
//       for (var i = 1; i <= 12; i++) {
//         final monthStart = DateTime(year, i, 1);
//         final monthEnd = i < 12
//             ? DateTime(year, i + 1, 1)
//             : DateTime(year + 1, 1, 1);
//         final query = await expensesRef
//             .where('date', isGreaterThanOrEqualTo: monthStart.toIso8601String())
//             .where('date', isLessThan: monthEnd.toIso8601String())
//             .get();
//         final total = query.docs.fold(0.0, (acc, doc) {
//           final data = doc.data();
//           return acc + (data['amount'] as num).toDouble();
//         });
//         monthlyTotals[i.toString().padLeft(2, '0')] = total;
//       }
//       setState(() {
//         _monthlyExpenses = monthlyTotals;
//       });
//     } catch (e) {
//       _showSnackbar('Failed to fetch expenses: $e', color: Colors.red);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showSnackbar(String message, {Color? color}) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
//   }

//   Future<void> _addIncome() async {
//     if (_incomeAmountController.text.isEmpty) return;
//     if (_editingIncome == null) {
//       final entry = IncomeEntry(
//         id: '',
//         amount: double.tryParse(_incomeAmountController.text) ?? 0.0,
//         date: _incomeDate,
//         description: _incomeDescController.text,
//       );
//       logger.w('Adding income: ${entry.toMap()}');
//       await _service.addIncome(entry);
//       _showSnackbar('Income added!', color: Colors.grey);
//     } else {
//       final entry = IncomeEntry(
//         id: _editingIncome!.id,
//         amount: double.tryParse(_incomeAmountController.text) ?? 0.0,
//         date: _incomeDate,
//         description: _incomeDescController.text,
//       );
//       await _service.updateIncome(entry);
//       _showSnackbar('Income updated!', color: Colors.blue);
//     }
//     _incomeAmountController.clear();
//     _incomeDescController.clear();
//     setState(() {
//       _incomeDate = DateTime.now();
//       _editingIncome = null;
//     });
//     _fetchIncome();
//   }

//   void _startEditIncome(IncomeEntry entry) {
//     setState(() {
//       _editingIncome = entry;
//       _incomeAmountController.text = entry.amount.toString();
//       _incomeDescController.text = entry.description ?? '';
//       _incomeDate = entry.date;
//     });
//   }

//   Future<void> _deleteIncome(IncomeEntry entry) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Income Entry'),
//         content: const Text(
//           'Are you sure you want to delete this income entry?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await _service.deleteIncome(entry.id);
//       _showSnackbar('Income deleted!', color: Colors.red);
//       _fetchIncome();
//     }
//   }

//   Future<void> _setBudget() async {
//     if (_budgetYear == null || _budgetController.text.isEmpty) return;
//     final budget = Budget(
//       year: int.parse(_budgetYear!),
//       monthlyBudgets: {},
//       yearlyBudget: double.tryParse(_budgetController.text) ?? 0,
//     );
//     await _service.setBudget(budget);
//     _showSnackbar('Yearly budget saved!', color: Colors.blue);
//     _fetchBudget();
//   }

//   Future<void> _saveMonthlyBudgets() async {
//     if (_budgetYear == null) return;
//     final monthly = <String, double>{};
//     for (var i = 1; i <= 12; i++) {
//       final key = i.toString().padLeft(2, '0');
//       final val = double.tryParse(_monthlyControllers[key]?.text ?? '');
//       if (val != null) monthly[key] = val;
//     }
//     final budget = Budget(
//       year: int.parse(_budgetYear!),
//       monthlyBudgets: monthly,
//       yearlyBudget: _budget?.yearlyBudget ?? 0,
//     );
//     await _service.setBudget(budget);
//     _showSnackbar('Monthly budgets saved!', color: Colors.blue);
//     _fetchBudget();
//   }

//   double get _averageIncome {
//     if (_incomeEntries.isEmpty) return 0;
//     final now = DateTime.now();
//     final cutoff = DateTime(now.year, now.month - _avgMonths + 1, 1);
//     final filtered = _incomeEntries
//         .where((e) => e.date.isAfter(cutoff))
//         .toList();
//     if (filtered.isEmpty) return 0;
//     final total = filtered.fold(0.0, (totalSoFar, e) => totalSoFar + e.amount);
//     return total / _avgMonths;
//   }

//   double get _suggestedBudget => _averageIncome * 0.7;

//   bool get _hasIncome => _incomeEntries.isNotEmpty;
//   bool get _hasBudget =>
//       _budget != null &&
//       (_budget!.yearlyBudget > 0 || _budget!.monthlyBudgets.isNotEmpty);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Budget & Income')),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFB388FF), Color(0xFF8C9EFF), Color(0xFF80D8FF)],
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: _loading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 24),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.account_balance_wallet_rounded,
//                             size: 40,
//                             color: Colors.deepPurple,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             'Budget & Income',
//                             style: Theme.of(context).textTheme.headlineMedium
//                                 ?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple[700],
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Income Section
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 28),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.attach_money,
//                                   color: Colors.blue[700],
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Income',
//                                   style: Theme.of(context).textTheme.titleLarge
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: _incomeAmountController,
//                                     keyboardType:
//                                         const TextInputType.numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                     decoration: InputDecoration(
//                                       labelText: 'Amount',
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       prefixIcon: const Icon(
//                                         Icons.currency_rupee,
//                                       ),
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: TextField(
//                                     controller: _incomeDescController,
//                                     decoration: InputDecoration(
//                                       labelText: 'Description',
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       prefixIcon: const Icon(Icons.description),
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.calendar_today),
//                                   onPressed: () async {
//                                     final picked = await showDatePicker(
//                                       context: context,
//                                       initialDate: _incomeDate,
//                                       firstDate: DateTime(2000),
//                                       lastDate: DateTime(2100),
//                                     );
//                                     if (picked != null) {
//                                       setState(() => _incomeDate = picked);
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             AnimatedSwitcher(
//                               duration: const Duration(milliseconds: 300),
//                               child: _editingIncome == null
//                                   ? ElevatedButton.icon(
//                                       key: const ValueKey('add'),
//                                       onPressed: _addIncome,
//                                       icon: const Icon(Icons.add),
//                                       label: const Text('Add Income'),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color.fromARGB(
//                                           255,
//                                           184,
//                                           191,
//                                           200,
//                                         ),
//                                         shape: const StadiumBorder(),
//                                       ),
//                                     )
//                                   : Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         ElevatedButton.icon(
//                                           key: const ValueKey('update'),
//                                           onPressed: _addIncome,
//                                           icon: const Icon(Icons.save),
//                                           label: const Text('Update'),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor:
//                                                 const Color.fromARGB(
//                                                   255,
//                                                   79,
//                                                   121,
//                                                   156,
//                                                 ),
//                                             shape: const StadiumBorder(),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         ElevatedButton.icon(
//                                           onPressed: () {
//                                             setState(() {
//                                               _editingIncome = null;
//                                               _incomeAmountController.clear();
//                                               _incomeDescController.clear();
//                                               _incomeDate = DateTime.now();
//                                             });
//                                           },
//                                           icon: const Icon(Icons.cancel),
//                                           label: const Text('Cancel'),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red[300],
//                                             shape: const StadiumBorder(),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                             ),
//                             const SizedBox(height: 18),
//                             Text(
//                               'Income Entries',
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             if (!_hasIncome)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Icon(
//                                       Icons.inbox,
//                                       size: 48,
//                                       color: Colors.grey[400],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'No income entries yet.',
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ..._incomeEntries.map(
//                               (e) => AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: const EdgeInsets.symmetric(vertical: 4),
//                                 child: Card(
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: ListTile(
//                                     leading: CircleAvatar(
//                                       backgroundColor: const Color.fromARGB(
//                                         255,
//                                         200,
//                                         210,
//                                         230,
//                                       ),
//                                       child: const Icon(
//                                         Icons.attach_money,
//                                         color: Color.fromARGB(255, 44, 20, 46),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       NumberFormat.simpleCurrency().format(
//                                         e.amount,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       '${DateFormat.yMMMd().format(e.date)}${e.description != null && e.description!.isNotEmpty ? ' - ${e.description}' : ''}',
//                                     ),
//                                     trailing: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.edit),
//                                           tooltip: 'Edit',
//                                           onPressed: () => _startEditIncome(e),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete),
//                                           tooltip: 'Delete',
//                                           onPressed: () => _deleteIncome(e),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Yearly Budget Section
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 28),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.savings,
//                                   color: const Color.fromARGB(255, 143, 17, 8),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Yearly Budget',
//                                   style: Theme.of(context).textTheme.titleLarge
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: _budgetController,
//                                     keyboardType:
//                                         TextInputType.numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                     decoration: InputDecoration(
//                                       labelText: 'Yearly Budget',
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       prefixIcon: const Icon(
//                                         Icons.calendar_today,
//                                       ),
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton.icon(
//                                   onPressed: _setBudget,
//                                   icon: const Icon(Icons.save),
//                                   label: const Text('Save'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       184,
//                                       191,
//                                       200,
//                                     ),
//                                     shape: StadiumBorder(),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (_budget != null)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: Text(
//                                   'Current Yearly Budget: ₹${_budget!.yearlyBudget}',
//                                   style: TextStyle(
//                                     color: const Color.fromARGB(
//                                       255,
//                                       143,
//                                       17,
//                                       8,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Monthly Budgets Section
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 28),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.calendar_view_month,
//                                   color: Colors.orange,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Monthly Budgets',
//                                   style: Theme.of(context).textTheme.titleLarge
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             GridView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 3,
//                                     childAspectRatio:
//                                         1.6, // Adjusted for better fit
//                                     crossAxisSpacing: 8,
//                                     mainAxisSpacing: 12, // Increased spacing
//                                   ),
//                               itemCount: 12,
//                               itemBuilder: (context, i) {
//                                 final key = (i + 1).toString().padLeft(2, '0');
//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize:
//                                       MainAxisSize.min, // Prevent overflow
//                                   children: [
//                                     Text(
//                                       _months[i],
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 13, // Slightly smaller
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 6,
//                                     ), // Consistent spacing
//                                     Expanded(
//                                       // Make TextField flexible
//                                       child: TextField(
//                                         controller: _monthlyControllers[key],
//                                         keyboardType:
//                                             TextInputType.numberWithOptions(
//                                               decimal: true,
//                                             ),
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                         ), // Smaller text
//                                         decoration: InputDecoration(
//                                           hintText: 'Budget',
//                                           hintStyle: const TextStyle(
//                                             fontSize: 11,
//                                           ),
//                                           isDense: true,
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                 horizontal: 8,
//                                                 vertical: 10,
//                                               ), // Optimized padding
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               10,
//                                             ),
//                                           ),
//                                           prefixIcon: const Icon(
//                                             Icons.currency_rupee,
//                                             size: 16, // Smaller icon
//                                           ),
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                             const SizedBox(
//                               height: 16,
//                             ), // Add spacing before button
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: ElevatedButton.icon(
//                                 onPressed: _saveMonthlyBudgets,
//                                 icon: const Icon(Icons.save),
//                                 label: const Text('Save Monthly Budgets'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(
//                                     255,
//                                     184,
//                                     191,
//                                     200,
//                                   ),
//                                   shape: const StadiumBorder(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Budget Progress Section
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 28),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.show_chart, color: Colors.blue),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Budget Progress',
//                                   style: Theme.of(context).textTheme.titleLarge
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             GridView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 3,
//                                     childAspectRatio:
//                                         2.2, // Better aspect ratio
//                                     crossAxisSpacing: 8,
//                                     mainAxisSpacing: 12, // Increased spacing
//                                   ),
//                               itemCount: 12,
//                               itemBuilder: (context, i) {
//                                 final key = (i + 1).toString().padLeft(2, '0');
//                                 final spent = _monthlyExpenses[key] ?? 0;
//                                 final budget =
//                                     _budget?.monthlyBudgets[key] ?? 0;
//                                 final percent = budget > 0
//                                     ? (spent / budget).clamp(0.0, 1.0)
//                                     : 0.0;
//                                 final isCurrentMonth =
//                                     DateTime.now().month == i + 1;

//                                 return AnimatedContainer(
//                                   duration: const Duration(milliseconds: 400),
//                                   decoration: BoxDecoration(
//                                     gradient: isCurrentMonth
//                                         ? LinearGradient(
//                                             colors: [
//                                               Colors.deepPurple.shade100,
//                                               Colors.deepPurple.shade50,
//                                             ],
//                                           )
//                                         : null,
//                                     color: isCurrentMonth
//                                         ? Colors.deepPurple.withValues(
//                                             alpha: 0.1,
//                                           )
//                                         : null,
//                                     border: Border.all(
//                                       color: isCurrentMonth
//                                           ? Colors.deepPurple
//                                           : Colors.grey.shade300,
//                                       width: isCurrentMonth ? 2 : 1,
//                                     ),
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       if (isCurrentMonth)
//                                         BoxShadow(
//                                           color: Colors.deepPurple.withValues(
//                                             alpha: 0.2,
//                                           ),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.all(8),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize:
//                                         MainAxisSize.min, // Prevent overflow
//                                     children: [
//                                       Text(
//                                         _months[i],
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 12, // Slightly smaller
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Flexible(
//                                         // Make progress bar flexible
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                             6,
//                                           ),
//                                           child: LinearProgressIndicator(
//                                             value: percent,
//                                             backgroundColor:
//                                                 Colors.grey.shade200,
//                                             color: percent < 1.0
//                                                 ? Colors.deepPurple
//                                                 : Colors.red,
//                                             minHeight: 6, // Slightly smaller
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Flexible(
//                                         // Make text flexible
//                                         child: FittedBox(
//                                           // Scale text to fit
//                                           fit: BoxFit.scaleDown,
//                                           child: Text(
//                                             '₹${spent.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}',
//                                             style: const TextStyle(
//                                               fontSize: 10,
//                                             ),
//                                             maxLines: 1,
//                                           ),
//                                         ),
//                                       ),
//                                       Flexible(
//                                         // Make percentage text flexible
//                                         child: Text(
//                                           '${(percent * 100).toStringAsFixed(0)}%',
//                                           style: const TextStyle(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Analytics Section (Mini Bar Chart)
//                     if (_hasIncome || _hasBudget)
//                       Card(
//                         elevation: 6,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         margin: const EdgeInsets.only(bottom: 28),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.bar_chart, color: Colors.teal),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Income & Budget Trends',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleLarge
//                                         ?.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               SizedBox(
//                                 height: 180,
//                                 child: BarChart(
//                                   BarChartData(
//                                     alignment: BarChartAlignment.spaceAround,
//                                     maxY:
//                                         [
//                                           ..._incomeEntries.map(
//                                             (e) => e.amount,
//                                           ),
//                                           ...?_budget?.monthlyBudgets.values,
//                                         ].fold<double>(
//                                           0,
//                                           (prev, e) => e > prev ? e : prev,
//                                         ) *
//                                         1.2,
//                                     barTouchData: BarTouchData(enabled: true),
//                                     titlesData: FlTitlesData(
//                                       leftTitles: AxisTitles(
//                                         sideTitles: SideTitles(
//                                           showTitles: true,
//                                           reservedSize: 32,
//                                         ),
//                                       ),
//                                       bottomTitles: AxisTitles(
//                                         sideTitles: SideTitles(
//                                           showTitles: true,
//                                           getTitlesWidget: (value, meta) {
//                                             final idx = value.toInt();
//                                             if (idx < 0 || idx > 11) {
//                                               return const SizedBox();
//                                             }
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                 top: 4,
//                                               ),
//                                               child: Text(
//                                                 _months[idx],
//                                                 style: const TextStyle(
//                                                   fontSize: 10,
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           reservedSize: 28,
//                                         ),
//                                       ),
//                                       rightTitles: AxisTitles(
//                                         sideTitles: SideTitles(
//                                           showTitles: false,
//                                         ),
//                                       ),
//                                       topTitles: AxisTitles(
//                                         sideTitles: SideTitles(
//                                           showTitles: false,
//                                         ),
//                                       ),
//                                     ),
//                                     borderData: FlBorderData(show: false),
//                                     barGroups: List.generate(12, (i) {
//                                       final key = (i + 1).toString().padLeft(
//                                         2,
//                                         '0',
//                                       );
//                                       final income = _incomeEntries
//                                           .where((e) => e.date.month == i + 1)
//                                           .fold(
//                                             0.0,
//                                             (total, e) => total + e.amount,
//                                           );
//                                       final budget =
//                                           _budget?.monthlyBudgets[key] ?? 0;
//                                       return BarChartGroupData(
//                                         x: i,
//                                         barRods: [
//                                           BarChartRodData(
//                                             toY: income,
//                                             color: Colors.green,
//                                             width: 10,
//                                             borderRadius: BorderRadius.circular(
//                                               4,
//                                             ),
//                                           ),
//                                           BarChartRodData(
//                                             toY: budget,
//                                             color: Colors.deepPurple,
//                                             width: 10,
//                                             borderRadius: BorderRadius.circular(
//                                               4,
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     }),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 16,
//                                     height: 8,
//                                     color: Colors.green,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   const Text('Income'),
//                                   const SizedBox(width: 16),
//                                   Container(
//                                     width: 16,
//                                     height: 8,
//                                     color: Colors.deepPurple,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   const Text('Budget'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     // Average Income & Suggested Budget
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 28),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.lightbulb, color: Colors.teal),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'Average Income & Suggested Budget',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleLarge
//                                         ?.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 const Text('Average over: '),
//                                 DropdownButton<int>(
//                                   value: _avgMonths,
//                                   items: _monthOptions
//                                       .map(
//                                         (m) => DropdownMenuItem(
//                                           value: m,
//                                           child: Text('$m months'),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (val) {
//                                     if (val != null) {
//                                       setState(() => _avgMonths = val);
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Average Income: ${NumberFormat.simpleCurrency().format(_averageIncome)}',
//                               style: TextStyle(
//                                 color: Colors.teal[700],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'Suggested Budget (70%): ${NumberFormat.simpleCurrency().format(_suggestedBudget)}',
//                               style: TextStyle(
//                                 color: Colors.teal[700],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
