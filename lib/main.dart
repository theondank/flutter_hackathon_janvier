import 'package:flutter/material.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:flutter_hackathon/mobile_scanner_overlay.dart';
import 'package:flutter_hackathon/app_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hémycicle App',
      theme: ThemeData(
        primaryColor: const Color(0xFF002395), // French blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002395),
          secondary: const Color(0xFFED2939), // French red
        ),
        useMaterial3: true, // Enable Material 3 design
        fontFamily: 'Marianne', // French government's official font
      ),
      home: const MyHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
 

class MyHome extends StatelessWidget {
  const MyHome({super.key});

 
  Widget _buildItem(
      BuildContext context, String label, IconData icon, Widget page) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Acceuil'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue sur',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hémicycle Digital',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002395),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scannez le QR code d\'un député ou consultez la liste complète',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Ajoute les boutons pour scanner un QR code ou consulter la liste des députés
            _buildItem(
              context,
              'Scanner le QR code d\'un député',
              Icons.qr_code_scanner,
              const BarcodeScannerWithOverlay(),
            ),
            _buildItem(
              context,
              'Consulter la liste des députés',
              Icons.account_circle,
              const DeputesPage(),
            ),
          ],
        ),
      ),
    );
  }
}
