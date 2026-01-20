// FILE: lib/src/ui/home/pages/expenses_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/firestore_service.dart';

class ExpensesPage extends StatelessWidget {
  final String uid;
  final String groupId;
  final FirestoreService firestoreService;

  const ExpensesPage({
    super.key,
    required this.uid,
    required this.groupId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd MMM • HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await _promptExpense(context);
          if (res == null) return;
          await firestoreService.addExpense(
            groupId: groupId,
            title: res.title,
            amount: res.amount,
            paidByUid: uid,
            date: DateTime.now(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder(
            stream: firestoreService.watchRecentExpenses(groupId, limit: 50),
            builder: (context, snap) {
              final expenses = snap.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: cs.primary.withOpacity(0.12),
                            ),
                            child: Icon(Icons.receipt_long, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shared expenses', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(
                                  'Log purchases and keep everything transparent.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (expenses.isEmpty)
                    Expanded(
                      child: _EmptyState(
                        title: 'No expenses yet',
                        subtitle: 'Tap “Add” to log your first shared purchase.',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final e = expenses[i];
                          final when = dateFmt.format(e.date.toLocal());

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: cs.primary.withOpacity(0.10),
                                    ),
                                    child: Icon(Icons.shopping_cart_outlined, color: cs.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Paid by: ${e.paidBy} • $when',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: cs.primary.withOpacity(0.10),
                                      border: Border.all(color: cs.primary.withOpacity(0.16)),
                                    ),
                                    child: Text(
                                      '€${e.amount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: cs.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<_ExpenseInput?> _promptExpense(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final res = await showDialog<_ExpenseInput>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Item',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 3.50',
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
              if (title.isEmpty || amount <= 0) return;
              Navigator.pop(context, _ExpenseInput(title: title, amount: amount));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    titleCtrl.dispose();
    amountCtrl.dispose();
    return res;
  }
}

class _ExpenseInput {
  final String title;
  final double amount;

  const _ExpenseInput({required this.title, required this.amount});
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cs.primary.withOpacity(0.12),
                ),
                child: Icon(icon, size: 28, color: cs.primary),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}