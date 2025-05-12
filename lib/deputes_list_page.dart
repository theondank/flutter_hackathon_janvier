import 'package:flutter/material.dart';
import 'package:flutter_hackathon/modele/deputes.dart';
import 'package:flutter_hackathon/services/deputes_service.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:flutter_hackathon/app_bar.dart';

class DeputesListPage extends StatefulWidget {
  const DeputesListPage({Key? key}) : super(key: key);

  @override
  State<DeputesListPage> createState() => _DeputesListPageState();
}

class _DeputesListPageState extends State<DeputesListPage> {
  late Future<List<Depute>> _deputes;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _deputes = DeputeService.fetchDeputes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Liste des députés'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un député',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Depute>>(
              future: _deputes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun député trouvé'));
                }

                final deputes = snapshot.data!;
                final filteredDeputes = deputes.where((depute) {
                  final String fullName =
                      '${depute.PRENOM} ${depute.NOM}'.toLowerCase();
                  return _searchQuery.isEmpty ||
                      fullName.contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredDeputes.length,
                  itemBuilder: (context, index) {
                    final depute = filteredDeputes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://datan.fr/assets/imgs/deputes_webp/depute_${depute.IDENTIFIANT}_webp.webp'),
                      ),
                      title: Text('${depute.PRENOM} ${depute.NOM}'),
                      subtitle: Text(
                          '${depute.GROUPE_POLITIQUE_ABREGE} - ${depute.DEPARTEMENT}'),
                      onTap: () async {
                        // Navigate to deputy details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeputePage(
                              depute: depute,
                              entries: [], // Empty entries for now
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
