import 'package:flutter/material.dart';

import 'screens/title_screen.dart';
import 'theme/spell_colors.dart';

void main() {
  runApp(const SpellCombatApp());
}

class SpellCombatApp extends StatelessWidget {
  const SpellCombatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.dark().textTheme;
    return MaterialApp(
      title: 'Spell Combat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SpellColors.background,
        colorScheme: const ColorScheme.dark(
          surface: SpellColors.surface,
          primary: SpellColors.ember,
          onPrimary: Colors.white,
          secondary: SpellColors.arcane,
          onSecondary: Color(0xFF04141C),
          tertiary: SpellColors.mystic,
          onTertiary: Colors.white,
          onSurface: SpellColors.textPrimary,
          onSurfaceVariant: SpellColors.textMuted,
          outlineVariant: SpellColors.outline,
        ),
        textTheme: baseTextTheme,
        appBarTheme: const AppBarTheme(backgroundColor: SpellColors.background),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: SpellColors.ember,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF55504B)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 44)),
            side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF55504B))),
          ),
        ),
      ),
      home: const TitleScreen(),
    );
  }
}