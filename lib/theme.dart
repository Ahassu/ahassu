import 'package:flutter/material.dart';

const kPrimaryPurple = Color(0xFF7C5CFC);
const kLightPurple = Color(0xFFEDE7FF);
const kBackground = Color(0xFFF7F7FB);
const kGreen = Color(0xFF34A853);
const kBlue = Color(0xFF3B82F6);

/// Card block colours. Blue is the question, green is the answer — the cards
/// carry no labels, so these two grounds are what tells them apart. Kept as
/// tints rather than accents so a screen full of them still reads as one page.
const kQuestionBg = Color(0xFFDCE6F2);
const kQuestionInk = Color(0xFF1E4F91);
const kBestBg = Color(0xFFDFEDDC);
const kBestInk = Color(0xFF356B2E);

/// Weight badges — how hard the posting leans on an area.
const kCritical = Color(0xFFB3261E);
const kHigh = Color(0xFF8A6212);
const kSupport = Color(0xFF5A6472);

ThemeData buildAhassuTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryPurple,
      primary: kPrimaryPurple,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: kBackground,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kPrimaryPurple,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimaryPurple,
      linearTrackColor: kLightPurple,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? kGreen : Colors.transparent,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
  );
}
