// FILE: lib/src/ui/auth/register_page.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const RegisterPage({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final roomCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _roomFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool loading = false;
  String? error;
  bool _obscure = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    roomCtrl.dispose();
    _nameFocus.dispose();
    _roomFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      loading = true;
      error = null;
    });

    final room = int.tryParse(roomCtrl.text.trim()) ?? 0;
    if (room < 1 || room > 13) {
      setState(() {
        loading = false;
        error = 'Room number must be between 1 and 13';
      });
      return;
    }

    try {
      final cred = await widget.authService.register(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      await widget.firestoreService.ensureUserDoc(
        uid: cred.user!.uid,
        email: emailCtrl.text.trim(),
        name: nameCtrl.text.trim().isEmpty ? 'User' : nameCtrl.text.trim(),
        roomNumber: room,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                            child: Icon(Icons.person_add_alt_1, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Join your flat', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(
                                  'Pick your room (1–13) so the rotation can highlight you.',
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

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Details', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 14),

                          TextField(
                            controller: nameCtrl,
                            focusNode: _nameFocus,
                            enabled: !loading,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Name (optional)',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            onSubmitted: (_) => _roomFocus.requestFocus(),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: roomCtrl,
                            focusNode: _roomFocus,
                            enabled: !loading,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Room number (1–13)',
                              prefixIcon: Icon(Icons.meeting_room_outlined),
                              hintText: 'e.g. 6',
                            ),
                            onSubmitted: (_) => _emailFocus.requestFocus(),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: emailCtrl,
                            focusNode: _emailFocus,
                            enabled: !loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            onSubmitted: (_) => _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: passCtrl,
                            focusNode: _passFocus,
                            enabled: !loading,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure ? 'Show password' : 'Hide password',
                                onPressed: loading ? null : () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            onSubmitted: (_) => loading ? null : _register(),
                          ),

                          const SizedBox(height: 12),
                          if (error != null) ...[
                            _ErrorBanner(message: error!),
                            const SizedBox(height: 12),
                          ],

                          FilledButton.icon(
                            onPressed: loading ? null : _register,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(loading ? 'Creating...' : 'Create account'),
                          ),
                          const SizedBox(height: 10),

                          OutlinedButton.icon(
                            onPressed: loading ? null : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to login'),
                          ),
                        ],
                      ),
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