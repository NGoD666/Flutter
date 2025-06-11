import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan ini
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments as String; // userEmail dikirim sebagai String
          return MaterialPageRoute(
            builder: (context) => DashboardPage(userEmail: args),
          );
        }
        // Jika route tidak dikenal, kembalikan null
        return null;
      },
    );
  }
}
