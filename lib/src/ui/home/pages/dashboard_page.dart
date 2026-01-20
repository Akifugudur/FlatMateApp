// FILE: lib/src/ui/home/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/firestore_service.dart';
import '../../../utils/week_key.dart';

class DashboardPage extends StatelessWidget {
  final String uid;
  final String groupId;
  final String weekId;
  final FirestoreService firestoreService;

  const DashboardPage({
    super.key,
    required this.uid,
    required this.groupId,
    required this.weekId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    const roomCount = 13;
    const startRoom = 4;

    final duty = WeekKey.dutyRoom(startRoom: startRoom, roomCount: roomCount);
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd MMM • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard — ${WeekKey.prettyWeekLabel(weekId)}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Icon(Icons.rotate_right_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'This week duty',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                _Badge(text: WeekKey.prettyWeekLabel(weekId)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rotation is deterministic and advances weekly.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: cs.primary.withOpacity(0.08),
                                border: Border.all(color: cs.primary.withOpacity(0.14)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.home_rounded, color: cs.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Room $duty',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      color: cs.primary.withOpacity(0.12),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: cs.primary,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Start: Room $startRoom • Total rooms: $roomCount',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.receipt_long, color: cs.primary),
                ],
              ),
              const SizedBox(height: 10),

              StreamBuilder(
                stream: firestoreService.watchRecentExpenses(groupId, limit: 8),
                builder: (context, expSnap) {
                  final expenses = expSnap.data ?? [];
                  if (expenses.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No expenses yet. Add one from the Expenses tab.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: expenses.map((e) {
                      final when = dateFmt.format(e.date.toLocal());
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
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
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.primary.withOpacity(0.10),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
      ),
    );
  }
}