import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/opening/welcome_page.dart';
import 'pages/core/user/dashboard/dashboard-screen.dart';
import 'pages/core/user/education/education-screen.dart';
import 'pages/core/user/nutrition/nutrition-screen.dart';
import 'pages/core/user/mental/mental-screen.dart';
import 'pages/core/user/delivery/delivery.dart';
import 'pages/core/user/postpartum/postpartum-screen.dart';
import 'pages/core/user/kalkulator/kalkulator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Sign out user when app starts
  await FirebaseAuth.instance.signOut();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hadomi Inan',
      theme: _buildTheme(),
      home: FutureBuilder(
        // Check if Firebase is initialized
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan saat memuat aplikasi'),
            );
          }

          // Show loading screen while Firebase initializes
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Once Firebase is initialized, check authentication state
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Since we sign out on app start, this will always go to WelcomePage
              if (authSnapshot.hasData) {
                // Sign out any existing user
                FirebaseAuth.instance.signOut();
                return const WelcomePage();
              }

              return const WelcomePage();
            },
          );
        },
      ),
      routes: _buildRoutes(),
      onGenerateRoute: (settings) {
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Halaman "${settings.name}" tidak ditemukan'),
            ),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: const Color(0xFF6B57D2),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF6B57D2)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B57D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF9BA0B3),
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: const Color(0xFF6B57D2).withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6B57D2)),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9BA0B3)),
        hintStyle: const TextStyle(color: Color(0xFF9BA0B3)),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        shadowColor: const Color(0xFF6B57D2).withOpacity(0.1),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/dashboard': (context) => const DashboardScreen(),
      '/education': (context) => const EducationScreen(),
      '/nutrition': (context) => NutritionScreen(),
      '/mental': (context) => MentalHealthScreen(),
      '/delivery-prep': (context) => DeliveryPrepScreen(),
      '/postpartum': (context) => PostpartumScreen(),
      '/calculator': (context) => const PregnancyCalculatorScreen(),
    };
  }
}
