import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login/login_page.dart';
import 'screens/home/home_page.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://clzeyaiolwbztjpefkpz.supabase.co',
    anonKey: 'sb_publishable_NBoj-9vPojz_9jrZafa7Pw_EqXBVZFr',
  );

  runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const MyApp(),
  ),
); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme:
          AppTheme.darkTheme,

      themeMode:
          themeProvider.themeMode,

      home: Supabase.instance.client
                  .auth.currentSession ==
              null
          ? const LoginPage()
          : const HomePage(),
    );
  },
);
  }
}