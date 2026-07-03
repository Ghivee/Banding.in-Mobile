import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'constants/colors.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BandinginApp());
}

class BandinginApp extends StatelessWidget {
  const BandinginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banding.in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD6ECFB),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          shape: Border(
            bottom: BorderSide(
              color: Color(0xFF98CBEB),
              width: 1.5,
            ),
          ),
        ),
      ),
      // AuthGate — otomatis redirect berdasarkan status login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryBlue),
                    SizedBox(height: 16),
                    Text('Memuat...', style: TextStyle(color: greyText)),
                  ],
                ),
              ),
            );
          }

          // Sudah login → MainScreen
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // Belum login → LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
