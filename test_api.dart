import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/models/user_model.dart';
import 'lib/services/api_service.dart';

void main() async {
  try {
    print('Testing with headers...');
    var response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': '*/*',
      },
    );
    print('Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      var jsonList = json.decode(response.body) as List;
      print('Parsing 1st user...');
      var user = UserModel.fromJson(jsonList[0]);
      print('First user name: ${user.name}');
      
      // Testing the full service
      print('Testing ApiService...');
      var apiService = ApiService();
      var users = await apiService.fetchUsers();
      print('Successfully fetched ${users.length} users.');
    } else {
      print('Body: ${response.body}');
    }
  } catch (e, st) {
    print('General Error: $e\n$st');
  }
}
