import 'package:ebiblioteka_mobile/providers/theme_provider.dart';
import 'package:ebiblioteka_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          home: Login(),
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 101, 85, 143),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: const Color.fromARGB(255, 101, 85, 143),
              foregroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 101, 85, 143),
              secondary: Colors.purpleAccent,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              foregroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              secondary: Colors.purpleAccent,
            ),
          ),
        );
      },
    );
  }
}
