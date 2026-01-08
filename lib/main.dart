import 'package:flutter/material.dart';
import 'camera/camera_service.dart';
import 'camera/camera_page.dart';
import 'Home/home_page.dart';  // 👈 UBAH INI (dari 'Home/home_page.dart' jadi 'pages/home_page.dart')

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initCameras();
  } catch (e) {
    debugPrint("Error initializing cameras: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf Sense',
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF8BC34A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E7D32),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      // Tambahkan routes untuk navigasi yang lebih baik
      routes: {
        '/home': (context) => const HomePage(),
        '/camera': (context) => const CameraPage(),
      },
    );
  }
}