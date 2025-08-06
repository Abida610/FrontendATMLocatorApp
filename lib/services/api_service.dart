import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dab_app/models/recommendation.dart';
import 'package:dab_app/models/navigation.dart';
import 'package:dab_app/models/atm_details.dart';
class APIService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  Future<List<ATMRecommendation>> fetchATMRecommendations({
    required double latitude,
    required double longitude,
    double radius = 5000,
    int limit = 15,
  }) async {
    final url = Uri.parse(
        '$baseUrl/recommandation?latitude=$latitude&longitude=$longitude&radius=$radius&limit=$limit'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ATMRecommendation.fromJson(json)).toList();
    }  else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? 'Une erreur inconnue s\'est produite';
      throw Exception(errorMessage);
    }
  }
  Future<NavigationResponse> fetchNavigationRoute({
    required double userLatitude,
    required double userLongitude,
    required int atmId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/navigation'
      '?latitude=$userLatitude'
      '&longitude=$userLongitude'
      '&atm_id=$atmId'
    );
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return NavigationResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['detail']);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? 'Une erreur inconnue s\'est produite';
      throw Exception(errorMessage);
    }
  }
  Future<String> sendComplaint({
  required int atmId,
  required String email,
  required String description,
}) async {
  final url = Uri.parse('$baseUrl/complaints');
  final body = jsonEncode({
    "pid": atmId,
    "email": email,
    "description": description,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    final validation = json.decode(response.body);
    return validation["message"];

  } else {
    final errorData = json.decode(response.body);
    final errorMessage = errorData['detail'] ;
    throw Exception(errorMessage);
  }
}
  Future<List<ATMDetails>> fetchAllATMs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/atms'),
        headers: {
          'Content-Type': 'application/json',

        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ATMDetails.fromJson(json)).toList();
      } else {
        throw Exception(' ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(' $e');
    }
  }

}