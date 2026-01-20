// FILE: lib/src/ui/home/pages/settings_page.dart
import 'package:flutter/material.dart';

import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

class SettingsPage extends StatelessWidget {
  final AppUser appUser;
  final AuthService authService;
  final FirestoreService firestoreService;

  const SettingsPage({
    super.key,
    required this.appUser,
    required this.authService,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groupId = appUser.groupId;

    final displayName = (appUser.name.trim().isEmpty) ? appUser.email : appUser.name.trim();
    final secondary = (appUser.name.trim().isEmpty) ? '' : appUser.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Icon(Icons.person_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (secondary.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                secondary,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                    ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Pill(
                                  icon: Icons.shield_outlined,
                                  label: appUser.role,
                                  tone: cs.primary,
                                ),
                                if (appUser.roomNumber >= 1) _Pill(icon: Icons.meeting_room_outlined, label: 'Room ${appUser.roomNumber}', tone: cs.tertiary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (groupId != null)
                StreamBuilder(
                  stream: firestoreService.watchGroup(groupId),
                  builder: (context, snap) {
                    final group = snap.data;
                    if (group == null) {
                      return const Card(
                        child: ListTile(
                          leading: Icon(Icons.home_work_outlined),
                          title: Text('Loading group...'),
                        ),
                      );
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: cs.primary.withOpacity(0.10),
                                  ),
                                  child: Icon(Icons.home_work_rounded, color: cs.primary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(group.name, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Your flat group information',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: cs.primary.withOpacity(0.06),
                                border: Border.all(color: cs.primary.withOpacity(0.14)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Group ID',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          group.id,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _CountChip(label: 'Members', value: group.members.length.toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You are not in a group yet. Create or join a group to continue.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout_rounded, color: cs.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Session',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign out from this device.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                            ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => authService.logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: cs.onError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tone;

  const _Pill({
    required this.icon,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tone.withOpacity(0.10),
        border: Border.all(color: tone.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, color: tone),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final String value;

  const _CountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.tertiary.withOpacity(0.10),
        border: Border.all(color: cs.tertiary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.tertiary,
                ),
          ),
        ],
      ),
    );
  }
}