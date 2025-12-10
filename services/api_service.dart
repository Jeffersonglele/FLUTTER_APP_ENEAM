import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Corriger l'URL (enlever le double slash)
  static const String baseUrl = "http://127.0.0.1/FLUTTER_ENEAM";
  static const String apiKey = "123456789ABCDEF";

  // REGISTER (POST) - Corrigé
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required int age,
    required String sexe,
    required String password,
  }) async {
    try {
      print("Envoi de la requête à: $baseUrl/api.php");

      final resp = await http.post(
        Uri.parse(
          "$baseUrl/api.php",
        ), // Utiliser api.php au lieu de register.php
        headers: {
          "Content-Type": "application/json", // IMPORTANT: ajouter Content-Type
          "Jeff-API-KEY": apiKey,
        },
        body: jsonEncode({
          // Utiliser jsonEncode pour envoyer en JSON
          "nom": nom,
          "prenom": prenom,
          "age": age,
          "email": email,
          "sexe": sexe,
          "password": password,
        }),
      );

      print("Status Code: ${resp.statusCode}");
      print("Response Body: ${resp.body}");

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        return {
          "success": false,
          "message": "Erreur serveur : ${resp.statusCode}",
        };
      }
    } catch (e) {
      print("Exception dans register: $e");
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }

  // LOGIN - Corrigé
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api.php"), // Utiliser api.php
        headers: {"Content-Type": "application/json", "Jeff-API-KEY": apiKey},
        body: jsonEncode({
          "email": email,
          "password": password,
          "action": "login", // Ajouter un champ action
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Erreur serveur : ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }
}
