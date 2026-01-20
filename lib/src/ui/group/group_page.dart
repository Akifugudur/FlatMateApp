// FILE: lib/src/ui/group/group_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class GroupPage extends StatefulWidget {
  final String uid;
  final FirestoreService firestoreService;
  final AuthService authService;

  const GroupPage({
    super.key,
    required this.uid,
    required this.firestoreService,
    required this.authService,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final groupNameCtrl = TextEditingController();
  final joinCodeCtrl = TextEditingController();

  bool loading = false;
  String? error;
  String? createdGroupId;

  @override
  void dispose() {
    groupNameCtrl.dispose();
    joinCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    setState(() {
      loading = true;
      error = null;
      createdGroupId = null;
    });

    try {
      final id = await widget.firestoreService.createGroup(
        creatorUid: widget.uid,
        groupName: groupNameCtrl.text.trim().isEmpty ? 'My Flat' : groupNameCtrl.text.trim(),
      );
      setState(() => createdGroupId = id);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _joinGroup() async {
    setState(() {
      loading = true;
      error = null;
      createdGroupId = null;
    });

    try {
      await widget.firestoreService.joinGroup(
        uid: widget.uid,
        groupId: joinCodeCtrl.text.trim().toUpperCase(),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _copyGroupId(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group ID copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Setup'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: loading ? null : () => widget.authService.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
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
                            child: Icon(Icons.home_work_rounded, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Create or join your flat', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(
                                  'You only do this once. After joining, you’ll see Tasks and Expenses.',
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

                  if (error != null) ...[
                    _ErrorBanner(message: error!),
                    const SizedBox(height: 14),
                  ],

                  _SectionCard(
                    title: 'Create a new group',
                    subtitle: 'You’ll get a Group ID to share with your roommates.',
                    icon: Icons.add_circle_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: groupNameCtrl,
                          enabled: !loading,
                          decoration: const InputDecoration(
                            labelText: 'Group name',
                            hintText: 'e.g. 13A Uni Housing',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: loading ? null : _createGroup,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add),
                          label: Text(loading ? 'Creating...' : 'Create group'),
                        ),
                        if (createdGroupId != null) ...[
                          const SizedBox(height: 14),
                          _GroupIdCard(
                            groupId: createdGroupId!,
                            onCopy: _copyGroupId,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Join an existing group',
                    subtitle: 'Enter the Group ID you received (example: ABC123).',
                    icon: Icons.group_add_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: joinCodeCtrl,
                          enabled: !loading,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Group ID',
                            hintText: 'ABC123',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: loading ? null : _joinGroup,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: Text(loading ? 'Joining...' : 'Join group'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Tip: If you created a group, copy the ID and share it in your flat WhatsApp group.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.primary.withOpacity(0.10),
                  ),
                  child: Icon(icon, color: cs.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _GroupIdCard extends StatelessWidget {
  final String groupId;
  final Future<void> Function(String id) onCopy;

  const _GroupIdCard({
    required this.groupId,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Group ID',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  groupId,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Copy',
            onPressed: () => onCopy(groupId),
            icon: Icon(Icons.copy_rounded, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}