import 'package:flutter/material.dart';
import 'package:flutter_hackathon/views/auth/auth_gate.dart';
import 'package:flutter_hackathon/views/auth/login_page.dart';
import 'package:flutter_hackathon/views/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'services/auth_service.dart';
import 'controller/auth_controller.dart';
import 'views/auth/sign_up.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => http.Client()),
        Provider(create: (context) => AuthService(client: context.read())),
        ChangeNotifierProvider(create: (context) => AuthController(context.read())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hémycicle App',
      theme: ThemeData(
        primaryColor: const Color(0xFF002395),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002395),
          secondary: const Color(0xFFED2939),
        ),
        useMaterial3: true,
        fontFamily: 'Marianne',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignUpPage(),
        '/home': (context) => const MyHome(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}