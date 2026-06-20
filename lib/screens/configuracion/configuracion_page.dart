import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class ConfiguracionPage
    extends StatelessWidget {

  const ConfiguracionPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final themeProvider =
        Provider.of<ThemeProvider>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Configuración'),
      ),

      body: ListTile(

        leading: Icon(
          themeProvider.isDark
              ? Icons.dark_mode
              : Icons.light_mode,
        ),

        title: const Text(
          'Modo oscuro',
        ),

        trailing: Switch(
          value:
              themeProvider.isDark,

          onChanged: (value) {
            themeProvider
                .toggleTheme(value);
          },
        ),
      ),
    );
  }
}