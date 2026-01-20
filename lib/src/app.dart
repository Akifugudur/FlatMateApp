// FILE: lib/src/app.dart
import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/messaging_service.dart';
import 'ui/auth/auth_gate.dart';

class FlatMateApp extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;
  final MessagingService messagingService;

  const FlatMateApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.messagingService,
  });

  @override
  State<FlatMateApp> createState() => _FlatMateAppState();
}

class _FlatMateAppState extends State<FlatMateApp> {
  @override
  void initState() {
    super.initState();
    widget.messagingService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlatMate',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: AuthGate(
        authService: widget.authService,
        firestoreService: widget.firestoreService,
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final seed = const Color(0xFF4F46E5); // indigo-ish
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );

  final bg = isDark ? const Color(0xFF0B1020) : const Color(0xFFF7F8FC);
  final surface = isDark ? const Color(0xFF121A2E) : Colors.white;

  return base.copyWith(
    scaffoldBackgroundColor: bg,
    cardColor: surface,

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),

    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.25),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.25),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.035),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: base.textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: base.textTheme.labelLarge,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF111827),
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 66,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      indicatorColor: scheme.primary.withOpacity(isDark ? 0.25 : 0.15),
      labelTextStyle: WidgetStatePropertyAll(base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    ),

    dividerTheme: DividerThemeData(
      thickness: 1,
      space: 24,
      color: scheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.6),
    ),
  );
}