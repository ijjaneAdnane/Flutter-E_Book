import 'package:flutter/material.dart';
import 'package:gestion_biblio/Admin/add_book_page.dart';
import 'package:gestion_biblio/Admin/adminpage.dart';
import 'package:gestion_biblio/Admin/booklistpage.dart';
import 'package:gestion_biblio/Admin/editbookpage.dart'; // Importez EditBookPage
import 'package:gestion_biblio/Admin/userspage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_page.dart';
import 'screens/profilepage.dart';
import 'screens/reset_password_screen.dart'; // Page Reset Password
import 'screens/settings_page.dart';
import 'screens/sign_in_screen.dart'; // Page Sign-In
import 'screens/sign_up_screen.dart'; // Page Sign-Up
import 'screens/verification_code_screen.dart'; // Page Verification Code
import 'screens/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://fqxcjonhshhdjjzyoxhk.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxeGNqb25oc2hoZGpqenlveGhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUyNTAzMjEsImV4cCI6MjA1MDgyNjMyMX0.QPY8P8FoP5Qk1Ny6TShRnvaCURYaNQNzJNGYpsHdFzo', // Replace with your Supabase Anon Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      initialRoute: '/sign-in', // Initial route set to Sign-In
      routes: {
        '/': (context) => SignInScreen(), // Définir la route racine
        '/sign-up': (context) => SignUpScreen(),
        '/sign-in': (context) => SignInScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/verification-code': (context) => VerificationCodeScreen(),
        '/welcomePage': (context) => const WelcomePage(),
        '/home': (context) => HomePage(),
        '/adminpage': (context) => AdminPage(),
        '/addBookPage': (context) => AddBookPage(),
        '/profile': (context) => const ProfilePage(),
        '/bookList': (context) => BookListPage(),
        '/settings': (context) => const SettingsPage(),
        '/users': (context) => UsersPage(),
        '/editBook': (context) => EditBookPage(
            book: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
      },
    );
  }
}
