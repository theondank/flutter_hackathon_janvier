import 'dart:convert';
import 'package:flutter_hackathon/modele/deputes.dart';
import 'package:flutter_hackathon/modele/historique.dart';
import 'package:http/http.dart' as http;

class DeputeService {
  static const String _baseUrl =
      'http://192-168-155-81.traefik.me:80/api'; // ou IP locale

  static Future<List<Depute>> fetchDeputes() async {
    final response = await http.get(Uri.parse('$_baseUrl/deputes'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Depute.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des députés');
    }
  }

  static Future<List<Historique>> fetchHistoriqueByDeputeId(int id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/historique/depute/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json.containsKey('historique')) {
        final List<dynamic> historiqueList = json['historique'];
        return historiqueList.map((item) => Historique.fromJson(item)).toList();
      } else {
        // Cas rare : réponse 200 sans clé 'historique'
        return [];
      }
    } else if (response.statusCode == 404) {
      // Député non trouvé
      return [];
    } else {
      throw Exception(
          "Erreur lors de la récupération de l'historique (code ${response.statusCode})");
    }
  }
}
