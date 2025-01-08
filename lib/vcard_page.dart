import 'package:flutter/material.dart';

class VCardPage extends StatelessWidget {
  final String vCardData;

  const VCardPage({super.key, required this.vCardData});

  Map<String, String> parseVCard(String data) {
    final Map<String, String> vCardMap = {};
    final lines = data.split('\n');
    for (var line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        vCardMap[parts[0]] = parts[1];
      }
    }
    return vCardMap;
  }

  @override
  Widget build(BuildContext context) {
    final vCardMap = parseVCard(vCardData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations du personnel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vCardMap.containsKey('FN'))
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: const Text(
                    'Nom',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(vCardMap['FN']!),
                ),
              ),
            if (vCardMap.containsKey('ADR'))
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: const Text(
                    'Adresse',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(vCardMap['ADR']!),
                ),
              ),
            if (vCardMap.containsKey('EMAIL'))
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(vCardMap['EMAIL']!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}