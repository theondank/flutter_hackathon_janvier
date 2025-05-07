import 'package:flutter/material.dart';
import 'package:flutter_hackathon/views/home/header_section.dart';
import 'package:flutter_hackathon/views/home/action_button.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:flutter_hackathon/mobile_scanner_overlay.dart';
import 'package:flutter_hackathon/app_bar.dart';

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Accueil'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HeaderSection(),
            SizedBox(height: 24),
            ActionButton(
              label: "Scanner le QR code d'un député",
              icon: Icons.qr_code_scanner,
              destination: BarcodeScannerWithOverlay(),
            ),
            ActionButton(
              label: "Consulter la liste des députés",
              icon: Icons.account_circle,
              destination: DeputesPage(),
            ),
          ],
        ),
      ),
    );
  }
}
