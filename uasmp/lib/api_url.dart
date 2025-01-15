import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.1.24:5000';

  // Fetch profile by ID
  Future<Map<String, dynamic>> fetchProfile(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // Update profile by ID
  Future<bool> updateProfile(String id, String profileUrl) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/$id/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'profile': profileUrl}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // Register user
  Future<Map<String, dynamic>> registerUser(
      String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Fetch all content
  Future<List<dynamic>> fetchAllContent() async {
    final response = await http.get(Uri.parse('$baseUrl/content'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch content');
    }
  }

  // Fetch content by ID
  Future<Map<String, dynamic>> fetchContentById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/content/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch content');
    }
  }

  // Add new content
  Future<bool> addContent(
      String imageItem, String itemName, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'image_item': imageItem,
        'item_name': itemName,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add content');
    }
  }

  // Update content by ID
  Future<bool> updateContent(
      String id, String imageItem, String itemName, String description) async {
    final response = await http.put(
      Uri.parse('$baseUrl/content/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'image_item': imageItem,
        'item_name': itemName,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update content');
    }
  }

  // Delete content by ID
  Future<bool> deleteContent(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/content/$id'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete content');
    }
  }
}
