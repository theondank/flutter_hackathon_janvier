import 'package:flutter/material.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:flutter_hackathon/mobile_scanner_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hackathon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Hackathon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildItem(context, 'Scanner QR Code', Icons.qr_code_scanner,
                const BarcodeScannerWithOverlay()),
            _buildItem(
                context, 'Liste des Députés', Icons.list, const DeputesPage()),
          ],
        ),
      ),
    );
  }
}
