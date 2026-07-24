import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ar_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'core/storage/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.instance.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ARProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Light Theme based on Google Stitch design system tokens
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF000613), // Deep Indigo / Black
        secondary: Color(0xFF7F5700), // Golden Amber
        surface: Colors.white,
        error: Color(0xFFBA1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1C1B1B),
      ),
      scaffoldBackgroundColor: const Color(0xFFFCF9F8),
      textTheme: GoogleFonts.hankenGroteskTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFCF9F8),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF000613)),
        titleTextStyle: TextStyle(
          color: Color(0xFF000613),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return MaterialApp(
      title: 'NAND STORE',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const SplashScreen(),
    );
  }
}
