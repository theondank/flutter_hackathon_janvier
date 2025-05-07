import 'package:flutter/material.dart';
import 'package:flutter_hackathon/mobile_scanner_overlay.dart';
import 'package:flutter_hackathon/services/deputes_service.dart';
import 'package:flutter_hackathon/modele/deputes.dart';

void testDeputeParsing() {
  final testJson = {
    "identifiant": "123",
    "nom": "Test",
    "prenom": "Jean",
    "region": "TestRegion",
    "departement": "TestDept",
    "groupePolitiqueAbrege": "TEST",
    "groupePolitiqueComplet": "Test complet",
    "numeroCirconscription": "1",
    "profession": "Testeur"
  };
  
  try {
    final depute = Depute.fromJson(testJson);
    print('Parsing réussi: ${depute.NOM} ${depute.PRENOM}');
  } catch (e) {
    print('Échec du parsing: $e');
  }
}

// Appelez cette fonction quelque part (dans initState par exemple)

class DeputesPage extends StatefulWidget {
  const DeputesPage({super.key});

  @override
  _DeputesPageState createState() => _DeputesPageState();
}

class _DeputesPageState extends State<DeputesPage> {
  List<Depute> _deputes = [];
  List<Depute> _filteredDeputes = [];
  bool _isLoading = true;
  String? _errorMessage; // Nouveau: pour stocker les erreurs
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeputesData();
    _searchController.addListener(_filterDeputes);
    testDeputeParsing(); // Testez le parsing
  }

  void _filterDeputes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDeputes = _deputes.where((depute) {
        return depute.NOM.toLowerCase().contains(query) ||
               depute.PRENOM.toLowerCase().contains(query) ||
               depute.REGION.toLowerCase().contains(query) ||
               depute.DEPARTEMENT.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadDeputesData() async {
    try {
      final deputies = await DeputeService.fetchDeputes();
      setState(() {
        _deputes = deputies;
        _filteredDeputes = deputies;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      print('Erreur capturée: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les données: ${e.toString()}';
      });
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadDeputesData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredDeputes.isEmpty) {
      return const Center(child: Text('Aucun député trouvé'));
    }
    
    return ListView.builder(
      itemCount: _filteredDeputes.length,
      itemBuilder: (context, index) {
        final depute = _filteredDeputes[index];
        return _buildDeputeCard(depute);
      },
    );
  }

  Widget _buildDeputeCard(Depute depute) {
    final imageUrl = 'https://datan.fr/assets/imgs/deputes_webp/depute_${depute.IDENTIFIANT}_webp.webp';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (exception, stackTrace) {
            print('Erreur de chargement image: $exception');
          },
          radius: 25,
        ),
        title: Text('${depute.PRENOM} ${depute.NOM}'),
        subtitle: Text('${depute.REGION}, ${depute.DEPARTEMENT}'),
        trailing: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey.shade200,
          ),
          child: Text(
            depute.GROUPE_POLITIQUE_ABREGE,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeputePage(
                depute: depute,
                entries: [],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DeputePage extends StatelessWidget {
  final Depute depute;
  final List<dynamic> entries;

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
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                'Historique',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry['title'] ?? ''),
                    subtitle: Text(entry['date'] ?? ''),
                  );
                },
              ),
            ]
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}