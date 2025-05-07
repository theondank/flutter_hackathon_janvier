import 'dart:convert';
import 'package:flutter_hackathon/modele/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://192-168-155-81.traefik.me:80/api';
  final http.Client client;

  AuthService({required this.client});

  Future<User> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/login');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur de connexion');
    }
  }

  Future<User> register(String name, String email, String password) async {
    final uri = Uri.parse('$_baseUrl/register');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'inscription');
    }
  }

  Future<User?> checkAuth(String token) async {
    final uri = Uri.parse('$_baseUrl/user');

    final response = await client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse('$_baseUrl/logout');

    final response = await client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la déconnexion');
    }
  }
} 