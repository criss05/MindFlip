import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'socket_service.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {

  static String get baseUrl => dotenv.env['SERVER_IP'] ?? 'http://localhost:3000';

  final SocketService socketService;

  final Function(Map<String, dynamic>) onCategoryCreated;
  final Function(Map<String, dynamic>) onCategoryUpdated;
  final Function(int) onCategoryDeleted;
  final Function(Map<String, dynamic>) onFlashcardCreated;
  final Function(Map<String, dynamic>) onFlashcardUpdated;
  final Function(int) onFlashcardDeleted;

  ApiService({
    required this.socketService,
    required this.onCategoryCreated,
    required this.onCategoryUpdated,
    required this.onCategoryDeleted,
    required this.onFlashcardCreated,
    required this.onFlashcardUpdated,
    required this.onFlashcardDeleted,
  }) {
    _attachListeners();
  }

  void _attachListeners() {
    final socket = socketService.socket;
    socket.on('category_created', (data) => onCategoryCreated(data));
    socket.on('category_updated', (data) => onCategoryUpdated(data));
    socket.on('category_deleted', (data) => onCategoryDeleted(data['id']));
    socket.on('flashcard_created', (data) => onFlashcardCreated(data));
    socket.on('flashcard_updated', (data) => onFlashcardUpdated(data));
    socket.on('flashcard_deleted', (data) => onFlashcardDeleted(data['id']));
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (socketService.socketId != null) {
      headers['x-socket-id'] = socketService.socketId!;
    }
    return headers;
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      debugPrint("SERVER ERROR [${response.statusCode}]: ${response.body}");

      String? customErrorMessage;

      try {
        final body = json.decode(response.body);
        if (body['error'] != null) {
          customErrorMessage = body['error'];
        }
      } catch (e) {}

      if (customErrorMessage != null) {
        throw Exception(customErrorMessage);
      }

      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchFullSync() async {
    final response = await http.get(Uri.parse('$baseUrl/sync'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load sync data');
  }

  Future<int> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/category'),
      headers: _headers,
      body: json.encode({
        'name': category.name,
        'lastModified': category.lastModified,
      }),
    );
    _handleError(response);
    return json.decode(response.body)['id'];
  }

  Future<void> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/category/${category.serverId}'),
      headers: _headers,
      body: json.encode({
        'name': category.name,
        'lastModified': category.lastModified,
      }),
    );
    _handleError(response);
  }

  Future<void> deleteCategory(int serverId) async {
    final response = await http.delete(Uri.parse('$baseUrl/category/$serverId'), headers: _headers);
    _handleError(response);
  }

  Future<int> createFlashcard(Flashcard flashcard) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flashcard'),
      headers: _headers,
      body: json.encode({
        'question': flashcard.question,
        'answer': flashcard.answer,
        'difficulty': flashcard.difficulty.index,
        'categoryId': flashcard.categoryId,
        'lastModified': flashcard.lastModified,
      }),
    );
    _handleError(response);
    return json.decode(response.body)['id'];
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    final response = await http.put(
      Uri.parse('$baseUrl/flashcard/${flashcard.serverId}'),
      headers: _headers,
      body: json.encode({
        'question': flashcard.question,
        'answer': flashcard.answer,
        'difficulty': flashcard.difficulty.index,
        'lastModified': flashcard.lastModified,
      }),
    );
    _handleError(response);
  }

  Future<void> deleteFlashcard(int serverId) async {
    final response = await http.delete(Uri.parse('$baseUrl/flashcard/$serverId'), headers: _headers);
    _handleError(response);
  }
}