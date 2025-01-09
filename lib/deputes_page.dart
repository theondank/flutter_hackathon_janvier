import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter_hackathon/database_helpers.dart';

final dbHelper = DatabaseHelper();
List<Map<String, String>>? _cachedDeputesData;

Future<List<Map<String, String>>> loadDeputesData() async {
  if (_cachedDeputesData != null) {
    return _cachedDeputesData!;
  }

  try {
    final data = await rootBundle.loadString('assets/data_deputes.csv');
    final List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

    if (csvTable.isEmpty) return [];

    final headers = csvTable.first.map((header) => header.toString()).toList();
    _cachedDeputesData = csvTable.skip(1).map((row) {
      return Map<String, String>.fromIterables(headers, row.map((e) => e.toString()));
    }).toList();

    return _cachedDeputesData!;
  } catch (e) {
    // Gestion des erreurs (par exemple, log ou affichage à l'utilisateur)
    return [];
  }
}

class DeputesPage extends StatefulWidget {
  const DeputesPage({super.key});

  @override
  _DeputesPageState createState() => _DeputesPageState();
}

class _DeputesPageState extends State<DeputesPage> {
  List<Map<String, String>> _deputes = [];

  @override
  void initState() {
    super.initState();
    _loadDeputesData();
  }

  Future<void> _loadDeputesData() async {
    final deputies = await loadDeputesData();
    setState(() {
      _deputes = deputies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Députés'),
      ),
      body: _deputes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _deputes.length,
              itemBuilder: (context, index) {
                final depute = _deputes[index];
                 String imageUrl =
                    'https://datan.fr/assets/imgs/deputes_webp/depute_${depute['identifiant']}_webp.webp';
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Image.network(imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text('${depute['Nom']} ${depute['Prénom']}'),
                    subtitle: Text('${depute['Région']}, ${depute['Circonscription']}'),
                    trailing: Text(depute['Groupe abrégé'] ?? ''),
                    onTap: () async {
                      List<Map<String, dynamic>> entries = await 
                      dbHelper.getEntriesForDepute('${depute['Nom']} ${depute['Prénom']}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeputePage(
                            depute: depute,
                            entries: entries,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DeputePage extends StatelessWidget {
  final Map<String, String> depute;
  final List<Map<String, dynamic>> entries;

  const DeputePage({super.key, required this.depute, required this.entries});

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        'https://datan.fr/assets/imgs/deputes_webp/depute_${depute['identifiant']}_webp.webp';
    return Scaffold(
      appBar: AppBar(
        title: Text('${depute['Nom']} ${depute['Prénom']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(imageUrl,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16.0),
            Text('Nom: ${depute['Nom']} ${depute['Prénom']}',
                style: const TextStyle(fontSize: 18)),
            Text('Région: ${depute['Région']}', style: const TextStyle(fontSize: 18)),
            Text('Circonscription: ${depute['Circonscription']}',
                style: const TextStyle(fontSize: 18)),
            Text('Groupe politique (abrégé): ${depute['Groupe abrégé']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16.0),
            const Text(
              'Historique des entrées dans l\'hémicycle:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  var entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          entry['deputy_name'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        entry['deputy_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(entry['entry_time']),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Action à effectuer lors du tap sur une entrée
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
