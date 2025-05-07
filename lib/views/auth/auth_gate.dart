import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hackathon/controller/auth_controller.dart';
import 'package:flutter_hackathon/views/home/home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthController>(context, listen: false).checkAuth(),
      builder: (context, snapshot) {
        final authController = Provider.of<AuthController>(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginPage(); // Redirige vers login en cas d'erreur
        }

        return authController.currentUser != null 
            ? const MyHome() 
            : const LoginPage();
      },
    );
  }
}