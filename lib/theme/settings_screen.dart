import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Truawake/theme/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor, // 👈 Use theme background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Theme",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // System Default Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "System Default",
                style: theme.textTheme.bodyLarge,
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeProvider.setTheme(mode);
                  }
                },
              ),
            ),

            // Light Mode Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Light Mode",
                style: theme.textTheme.bodyLarge,
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeProvider.setTheme(mode);
                  }
                },
              ),
            ),

            // Dark Mode Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Dark Mode",
                style: theme.textTheme.bodyLarge,
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeProvider.setTheme(mode);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
