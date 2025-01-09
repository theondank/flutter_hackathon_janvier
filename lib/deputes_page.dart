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
  List<Map<String, String>> _filteredDeputes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeputesData();
    _searchController.addListener(_filterDeputes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDeputes);
    super.dispose();
  }

  Future<void> _loadDeputesData() async {
    final deputies = await loadDeputesData();
    setState(() {
      _deputes = deputies;
      _filteredDeputes = deputies;
    });
  }

  void _filterDeputes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDeputes = _deputes.where((depute) {
        final name = '${depute['Nom']} ${depute['Prénom']}'.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Députés'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _deputes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredDeputes.length,
              itemBuilder: (context, index) {
                final depute = _filteredDeputes[index];
                String imageUrl =
                    'https://datan.fr/assets/imgs/deputes_webp/depute_${depute['identifiant']}_webp.webp';
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Image.network(imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text('${depute['Nom']} ${depute['Prénom']}'),
                    subtitle: Text('${depute['Région']}, ${depute['Département']}'),
                    trailing: Text(depute['Groupe politique (abrégé)'] ?? ''),
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
            Text('Circonscription: ${depute['Département']}',
                style: const TextStyle(fontSize: 18)),
            Text('Groupe politique (abrégé): ${depute['Groupe politique (abrégé)']}',
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
                      trailing: const Icon(Icons.arrow_forward),
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
