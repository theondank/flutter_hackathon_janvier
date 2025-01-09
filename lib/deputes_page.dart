// Importation des packages nécessaires
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter_hackathon/database_helpers.dart';

// Instance du gestionnaire de base de données
final dbHelper = DatabaseHelper();

// Variable pour mettre en cache les données des députés
List<Map<String, String>>? _cachedDeputesData;

// Fonction pour charger les données des députés depuis un fichier CSV
Future<List<Map<String, String>>> loadDeputesData() async {
  // Si les données sont déjà en cache, les retourner directement
  if (_cachedDeputesData != null) {
    return _cachedDeputesData!;
  }

  try {
    
    final data = await rootBundle.loadString('assets/data_deputes.csv');
    final List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

  
    if (csvTable.isEmpty) return [];

    // Extraction des en-têtes et des données
    final headers = csvTable.first.map((header) => header.toString()).toList();
    _cachedDeputesData = csvTable.skip(1).map((row) {
      return Map<String, String>.fromIterables(headers, row.map((e) => e.toString()));
    }).toList();

    return _cachedDeputesData!;
  } catch (e) {
    
    return [];
  }
}

// Classe principale pour afficher la liste des députés
class DeputesPage extends StatefulWidget {
  const DeputesPage({super.key});

  @override
  _DeputesPageState createState() => _DeputesPageState();
}

class _DeputesPageState extends State<DeputesPage> {
  List<Map<String, String>> _deputes = []; // Liste complète des députés
  List<Map<String, String>> _filteredDeputes = []; // Liste filtrée selon la recherche
  TextEditingController _searchController = TextEditingController(); // Contrôleur pour le champ de recherche

  @override
  void initState() {
    super.initState();
    _loadDeputesData(); // Charger les données des députés
    _searchController.addListener(_filterDeputes); // Écoute les modifications du champ de recherche
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDeputes);
    super.dispose();
  }

  // Charger les données des députés 
  Future<void> _loadDeputesData() async {
    final deputies = await loadDeputesData();
    setState(() {
      _deputes = deputies;
      _filteredDeputes = deputies;
    });
  }

  // Filtre les députés en fonction de la saisie de l'utilisateur
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
                      // Charge l'historique d'entrée pour le député et ouvre une page détaillée
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

// Page détaillée pour un député spécifique
class DeputePage extends StatelessWidget {
  final Map<String, String> depute; // Informations sur le député
  final List<Map<String, dynamic>> entries; // Historique des entrées du député

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
