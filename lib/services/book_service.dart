import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String apiKey = 'AIzaSyD83nD_YintO_BE2RpKFZ5Qnq6qm8qTwdk';

  Future<List<dynamic>> fetchBooks(String query) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      }
    } catch (e) {
      print("Error fetching books: $e");
    }
    return [];
  }
}