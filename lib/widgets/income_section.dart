import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/income_entry.dart';

class IncomeSection extends StatelessWidget {
  final TextEditingController incomeAmountController;
  final TextEditingController incomeDescController;
  final DateTime incomeDate;
  final IncomeEntry? editingIncome;
  final VoidCallback onAddIncome;
  final VoidCallback onUpdateIncome;
  final VoidCallback onCancelEdit;
  final Function(IncomeEntry) onDeleteIncome;
  final Function(IncomeEntry) onEditIncome;
  final List<IncomeEntry> incomeEntries;
  final ValueChanged<DateTime> onDateChanged;

  const IncomeSection({
    super.key,
    required this.incomeAmountController,
    required this.incomeDescController,
    required this.incomeDate,
    required this.editingIncome,
    required this.onAddIncome,
    required this.onUpdateIncome,
    required this.onCancelEdit,
    required this.onDeleteIncome,
    required this.onEditIncome,
    required this.incomeEntries,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.attach_money,
      title: 'Income',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIncomeForm(context),
          const SizedBox(height: 18),
          _buildIncomeList(context),
        ],
      ),
      context: context,
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 28),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeForm(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: TextField(
            controller: incomeAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _buildInputDecoration(
              'Amount',
              Icons.currency_rupee,
              context,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: TextField(
            controller: incomeDescController,
            decoration: _buildInputDecoration(
              'Description',
              Icons.description,
              context,
            ),
          ),
        ),
        _buildDatePicker(context),
        _buildIncomeActionButton(context),
        if (editingIncome != null) _buildCancelEditButton(context),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: incomeDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
    );
  }

  Widget _buildIncomeActionButton(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: editingIncome == null
          ? ElevatedButton.icon(
              key: const ValueKey('add'),
              onPressed: onAddIncome,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: _buildButtonStyle(context),
            )
          : ElevatedButton.icon(
              key: const ValueKey('update'),
              onPressed: onUpdateIncome,
              icon: const Icon(Icons.save),
              label: const Text('Update'),
              style: _buildButtonStyle(context),
            ),
    );
  }

  ButtonStyle _buildButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
    );
  }

  Widget _buildCancelEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear),
      tooltip: 'Cancel Edit',
      onPressed: onCancelEdit,
    );
  }

  Widget _buildIncomeList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income Entries',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (incomeEntries.isEmpty) _buildEmptyState(),
        ...incomeEntries.map((entry) => _buildIncomeItem(context, entry)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No income entries yet.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(BuildContext context, IncomeEntry entry) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(
              Icons.attach_money,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(NumberFormat.simpleCurrency().format(entry.amount)),
          subtitle: Text(
            '${DateFormat.yMMMd().format(entry.date)}${entry.description != null && entry.description!.isNotEmpty ? ' - ${entry.description}' : ''}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => onEditIncome(entry),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () => onDeleteIncome(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
