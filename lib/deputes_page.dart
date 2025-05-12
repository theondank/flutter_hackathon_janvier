import 'package:flutter/material.dart';
import 'package:flutter_hackathon/modele/deputes.dart';
import 'package:flutter_hackathon/modele/historique.dart';
import 'package:intl/intl.dart';

class DeputePage extends StatelessWidget {
  final Depute depute;
  final List<Map<String, dynamic>> entries;

  const DeputePage({
    Key? key,
    required this.depute,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        'https://datan.fr/assets/imgs/deputes_webp/depute_${depute.IDENTIFIANT}_webp.webp';

    return Scaffold(
      appBar: AppBar(
        title: Text('${depute.PRENOM} ${depute.NOM}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 60,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${depute.PRENOM} ${depute.NOM}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    _infoRow('Groupe', depute.GROUPE_POLITIQUE_COMPLET),
                    _infoRow('Région', depute.REGION),
                    _infoRow('Département', depute.DEPARTEMENT),
                    _infoRow('Circonscription', depute.NUMERO_CIRCONSCRIPTION),
                    _infoRow('Profession', depute.PROFESSION),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Historique',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            if (entries.isEmpty)
              const Text(
                'Aucun historique pour ce député.',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(entry['title'] ?? ''),
                    subtitle: Text(
                      _formatDate(entry['date']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
    } catch (_) {
      return dateStr; // fallback brut si parsing échoue
    }
  }
}
