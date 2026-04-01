import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonBody = json.decode(response.body);
        return jsonBody.map((json) => UserModel.fromJson(json)).toList();
      } else {
        // Log detailed error for debugging
        print('API Error Body: ${response.body}');
        throw Exception('Status ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Network/Parsing Error: $e');
      rethrow;
    }
  }
}
