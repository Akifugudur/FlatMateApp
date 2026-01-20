// FILE: lib/src/ui/home/pages/tasks_page.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/week_key.dart';

class TasksPage extends StatelessWidget {
  final String groupId; // unused; kept for compatibility
  final String weekId;

  const TasksPage({
    super.key,
    required this.groupId,
    required this.weekId,
  });

  @override
  Widget build(BuildContext context) {
    const roomCount = 13;
    const startRoom = 4;

    final duty = WeekKey.dutyRoom(startRoom: startRoom, roomCount: roomCount);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task — ${WeekKey.prettyWeekLabel(weekId)}'),
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
                                    'Weekly duty rotation',
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
                              'Only one duty exists. The highlighted room handles everything this week.',
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
                                      'This week: Room $duty',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _RoomPieChart(
                      roomCount: roomCount,
                      highlightedRoom: duty,
                      size: 320,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: cs.tertiary.withOpacity(0.12),
                        ),
                        child: Icon(Icons.info_outline_rounded, color: cs.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rotation rules',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Starts at Room $startRoom and advances +1 every week (even if rooms are empty).',
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

              const SizedBox(height: 8),
              Text(
                'Tip: You can mention in the report that the rotation is deterministic (ISO week-based) and does not require database writes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                    ),
              ),
              const SizedBox(height: 8),
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

class _RoomPieChart extends StatelessWidget {
  final int roomCount;
  final int highlightedRoom;
  final double size;

  const _RoomPieChart({
    required this.roomCount,
    required this.highlightedRoom,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoomPiePainter(
          roomCount: roomCount,
          highlightedRoom: highlightedRoom,
          theme: Theme.of(context),
        ),
      ),
    );
  }
}

class _RoomPiePainter extends CustomPainter {
  final int roomCount;
  final int highlightedRoom;
  final ThemeData theme;

  _RoomPiePainter({
    required this.roomCount,
    required this.highlightedRoom,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final slice = (2 * math.pi) / roomCount;
    final startBase = -math.pi / 2;

    final base = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    // subtle outer ring
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = onSurface.withOpacity(0.06);
    canvas.drawCircle(center, radius + 4, ring);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < roomCount; i++) {
      final room = i + 1;
      final startAngle = startBase + i * slice;
      final isActive = room == highlightedRoom;

      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = base.withOpacity(isActive ? 0.94 : 0.16);

      border.color = onSurface.withOpacity(isActive ? 0.55 : 0.16);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        slice,
        true,
        fill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        slice,
        true,
        border,
      );

      final mid = startAngle + slice / 2;
      final labelRadius = radius * (isActive ? 0.72 : 0.68);
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(mid),
        center.dy + labelRadius * math.sin(mid),
      );

      final labelBg = Paint()..color = surface.withOpacity(isActive ? 0.95 : 0.85);
      canvas.drawCircle(labelPos, isActive ? 16 : 13, labelBg);

      final tp = TextPainter(
        text: TextSpan(
          text: room.toString(),
          style: TextStyle(
            fontSize: isActive ? 15 : 11,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            color: onSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }

    // center badge
    final centerRadius = radius * 0.24;
    canvas.drawCircle(center, centerRadius, Paint()..color = surface.withOpacity(0.96));
    canvas.drawCircle(
      center,
      centerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = base.withOpacity(0.18),
    );

    final centerTp = TextPainter(
      text: TextSpan(
        text: 'ROOM\n$highlightedRoom',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: onSurface,
          height: 1.12,
          letterSpacing: 0.5,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    centerTp.paint(canvas, center - Offset(centerTp.width / 2, centerTp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoomPiePainter oldDelegate) {
    return oldDelegate.highlightedRoom != highlightedRoom || oldDelegate.roomCount != roomCount;
  }
}