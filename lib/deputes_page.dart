import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<Map<String, String>>> loadDeputesData() async {
  final data = await rootBundle.loadString('assets/data_deputes.csv');
  final List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

  final headers = csvTable[0].map((header) => header.toString()).toList();
  final List<Map<String, String>> deputes = [];

  for (var i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];
    final Map<String, String> depute = {};
    for (var j = 0; j < headers.length; j++) {
      depute[headers[j]] = row[j].toString();
    }
    deputes.add(depute);
  }

  return deputes;
}

Future<bool> verifyDeputyData(
    Map<String, String> vCardData, List<Map<String, String>> deputies) async {
  for (final deputy in deputies) {
    if (vCardData['Nom complet'] == '${deputy['Nom']} ${deputy['Prénom']}') {
      // Vous pouvez ajouter d'autres comparaisons ici (Email, Téléphone, etc.)
      return true;
    }
  }
  return false;
}

class DeputesPage extends StatefulWidget {
  const DeputesPage({super.key});

  @override
  _DeputesPageState createState() => _DeputesPageState();
}

class _DeputesPageState extends State<DeputesPage> {
  List<List<dynamic>> _deputes = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final rawData = await rootBundle.loadString('assets/data_deputes.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    setState(() {
      _deputes = listData;
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('${depute[1]} ${depute[2]}'),
                    subtitle: Text('${depute[3]}, ${depute[4]}'),
                    trailing: Text(depute[8]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeputePage(
                            deputeData: {
                              'Nom': depute[1],
                              'Prénom': depute[2],
                              'Parti': depute[3],
                              'Circonscription': depute[4],
                              'Email': depute[8],
                            },
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
  final Map<String, String> deputeData;

  const DeputePage({super.key, required this.deputeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations du Député'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: deputeData.entries.map((entry) {
            return Text('${entry.key}: ${entry.value}');
          }).toList(),
        ),
      ),
    );
  }
}
