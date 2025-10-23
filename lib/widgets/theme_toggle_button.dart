import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.system
                ? Icons.brightness_6
                : themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: themeProvider.themeMode == ThemeMode.system
              ? 'Switch to manual theme'
              : 'Toggle theme',
        );
      },
    );
  }
}