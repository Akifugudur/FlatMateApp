// FILE: lib/src/ui/auth/login_page.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const LoginPage({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool loading = false;
  String? error;
  bool _obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final cred = await widget.authService.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      final user = cred.user;
      if (user == null) return;

      final exists = await widget.firestoreService.userDocExists(user.uid);
      if (!exists) {
        final room = await _promptRoomNumber(context);
        if (room == null) {
          await widget.authService.logout();
          if (mounted) {
            setState(() => error = 'Room number required (1-13). Login cancelled.');
          }
          return;
        }

        await widget.firestoreService.ensureUserDoc(
          uid: user.uid,
          email: user.email ?? emailCtrl.text.trim(),
          name: 'Room $room',
          roomNumber: room,
        );
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<int?> _promptRoomNumber(BuildContext context) async {
    final ctrl = TextEditingController();
    final res = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Room number'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter 1-13'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim()) ?? 0;
              if (v < 1 || v > 13) return;
              Navigator.pop(context, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlatMate'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(colorScheme: cs),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Use your email and password to continue.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                                ),
                          ),
                          const SizedBox(height: 14),

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
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure ? 'Show password' : 'Hide password',
                                onPressed: loading ? null : () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            onSubmitted: (_) => loading ? null : _login(),
                          ),

                          const SizedBox(height: 12),
                          if (error != null) ...[
                            _ErrorBanner(message: error!),
                            const SizedBox(height: 12),
                          ],

                          FilledButton.icon(
                            onPressed: loading ? null : _login,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.login),
                            label: Text(loading ? 'Signing in...' : 'Login'),
                          ),
                          const SizedBox(height: 10),

                          OutlinedButton.icon(
                            onPressed: loading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => RegisterPage(
                                          authService: widget.authService,
                                          firestoreService: widget.firestoreService,
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Create account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tip: Room number will be asked only if your profile is missing.',
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

class _HeaderCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _HeaderCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.primary.withOpacity(0.12),
              ),
              child: Icon(Icons.home_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shared living, less chaos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tasks rotate weekly • Expenses stay transparent',
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