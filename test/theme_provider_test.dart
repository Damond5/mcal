import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mcal/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Initial theme mode is system', () {
    final themeProvider = ThemeProvider();
    expect(themeProvider.themeMode, ThemeMode.system);
  });

  test('setThemeMode updates theme', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();

    await themeProvider.setThemeMode(ThemeMode.light);
    expect(themeProvider.themeMode, ThemeMode.light);

    await themeProvider.setThemeMode(ThemeMode.dark);
    expect(themeProvider.themeMode, ThemeMode.dark);
  });

  test('toggleTheme cycles between light and dark when not system', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();

    await themeProvider.setThemeMode(ThemeMode.light);
    themeProvider.toggleTheme();
    expect(themeProvider.themeMode, ThemeMode.dark);

    themeProvider.toggleTheme();
    expect(themeProvider.themeMode, ThemeMode.light);
  });

  test('Theme persistence loads correctly', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 1}); // Light mode
    final themeProvider = ThemeProvider();

    // Wait for async load by checking until it's loaded
    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      return themeProvider.themeMode == ThemeMode.system; // Still default
    }).timeout(Duration(seconds: 1), onTimeout: () => null);

    expect(themeProvider.themeMode, ThemeMode.light);
  });

  test('isDarkMode logic', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();

    // System mode - depends on platform, but we can test the method
    expect(themeProvider.isDarkMode, isA<bool>());

    await themeProvider.setThemeMode(ThemeMode.light);
    expect(themeProvider.isDarkMode, false);

    await themeProvider.setThemeMode(ThemeMode.dark);
    expect(themeProvider.isDarkMode, true);
  });
}