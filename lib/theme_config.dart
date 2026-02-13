import 'package:flutter/material.dart';

class ThemeConfig {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Lato',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: const Color(0xFFF8FAFC),
      indicatorColor: Colors.black,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
    ),
    canvasColor: const Color(0xFFF8FAFC),
    primaryColor: Colors.black,
    dividerColor: Colors.black12,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.black,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.amber,
    scaffoldBackgroundColor: const Color(0XFF0F172A),
    fontFamily: 'Lato',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: const Color(0xFF020617),
      indicatorColor: const Color(0xFF60A5FA).withOpacity(0.2),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      selectedIconTheme: const IconThemeData(color: Color(0xFF60A5FA)),
      unselectedIconTheme: const IconThemeData(color: Colors.white38),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white38),
    ),
    canvasColor: const Color(0xFF020617),
    primaryColor: Colors.white,
    dividerColor: Colors.white10,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF60A5FA),
    ),
  );
}
