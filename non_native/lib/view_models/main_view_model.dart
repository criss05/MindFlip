import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../repositories/categories_repository.dart';
import '../repositories/flashcards_repository.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/category.dart';
import '../models/flashcard.dart';

enum ConnectionStatus { online, offline, serverDown }

class MainViewModel extends ChangeNotifier {
  final CategoriesRepository categoriesRepo;
  final FlashcardsRepository flashcardsRepo;
  final ApiService apiService;
  final SocketService socketService;

  List<Category> _categories = [];
  List<Flashcard> _flashcards = [];
  String? _errorMessage;
  String _searchQuery = '';
  ConnectionStatus _connectionStatus = ConnectionStatus.online;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _socketStatusSubscription;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _flashcardsSubscription;


  List<Category> get categories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }
  List<Flashcard> get flashcards => _flashcards;
  String? get errorMessage => _errorMessage;
  ConnectionStatus get connectionStatus => _connectionStatus;

  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  MainViewModel({
    required this.categoriesRepo,
    required this.flashcardsRepo,
    required this.apiService,
    required this.socketService,
  }) {
    _init();
  }

  void _init() {
    _categoriesSubscription?.cancel();
    _categoriesSubscription = categoriesRepo.getAllCategories().listen((data) {
      _categories = data;
      notifyListeners();
    });

    _socketStatusSubscription = socketService.connectionStatusStream.listen((isServerUp) {
      if (isServerUp) {
        _setConnectionStatus(ConnectionStatus.online);
        _performSync();
      } else {

        if (_connectionStatus != ConnectionStatus.offline) {
          _checkNetworkStatus(ConnectivityResult.wifi);
        }
      }
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result is List) {
        _checkNetworkStatus((result as List).first);
      } else {
        _checkNetworkStatus(result as ConnectivityResult);
      }
    });

    Connectivity().checkConnectivity().then((result) {
      if (result is List) {
        _checkNetworkStatus((result as List).first);
      } else {
        _checkNetworkStatus(result as ConnectivityResult);
      }
    });
  }

  void _setConnectionStatus(ConnectionStatus status) {
    if (_connectionStatus != status) {
      _connectionStatus = status;
      notifyListeners();
    }
  }

  Future<void> _checkNetworkStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _setConnectionStatus(ConnectionStatus.offline);
      return;
    }

    if (socketService.isConnected) {
      _setConnectionStatus(ConnectionStatus.online);
      _performSync();
      return;
    }

    try {
      final isServerUp = await apiService.checkServerHealth();
      if (socketService.isConnected) {
        _setConnectionStatus(ConnectionStatus.online);
        return;
      }
      if (isServerUp) {
        _setConnectionStatus(ConnectionStatus.online);
        _performSync();
      } else {
        _setConnectionStatus(ConnectionStatus.serverDown);
      }
    } catch (e) {
      _setConnectionStatus(ConnectionStatus.serverDown);
    }
  }

  Future<void> _performSync() async {
    if (_connectionStatus != ConnectionStatus.online) return;
    debugPrint("Performing Sync...");
    try {
      await categoriesRepo.syncPending();
      await flashcardsRepo.syncPending();
      final serverData = await apiService.fetchFullSync();
      if (serverData['categories'] != null) await categoriesRepo.syncFromServer(serverData['categories']);
      if (serverData['flashcards'] != null) await flashcardsRepo.syncFromServer(serverData['flashcards']);
    } catch (e) {
      debugPrint("Sync failed: $e");
    }
  }

  void selectCategory(int categoryId) {
    _flashcardsSubscription?.cancel();
    _flashcards = [];
    notifyListeners();
    _flashcardsSubscription = flashcardsRepo.getAllFlashcards(categoryId).listen((data) {
      _flashcards = data;
      notifyListeners();
    });
  }

  Future<void> addCategory(Category c) async {
    try { await categoriesRepo.addCategory(c); } catch (e) { _setError(e.toString()); }
  }
  Future<void> updateCategory(Category c) async {
    try { await categoriesRepo.updateCategory(c); } catch (e) { _setError(e.toString()); }
  }
  Future<void> deleteCategory(int id) async {
    try { await categoriesRepo.deleteCategory(id); } catch (e) { _setError(e.toString()); }
  }
  Future<void> addFlashcard(Flashcard f) async {
    try {
      await flashcardsRepo.addFlashcard(f);
      await categoriesRepo.incFlashcardCount(f.categoryId);
    } catch (e) { _setError(e.toString()); }
  }
  Future<void> updateFlashcard(Flashcard f) async {
    try { await flashcardsRepo.updateFlashcard(f); } catch (e) { _setError(e.toString()); }
  }
  Future<void> deleteFlashcard(int id, int categoryId) async {
    try {
      await flashcardsRepo.deleteFlashcard(id);
      await categoriesRepo.decFlashcardCount(categoryId);
    } catch (e) { _setError(e.toString()); }
  }

  Flashcard? getFlashcardById(int id) {
    try { return _flashcards.firstWhere((f) => f.localId == id); } catch (e) { return null; }
  }

  String getCategoryName(int categoryId) {
    try {
      final category = _categories.firstWhere((c) => c.localId == categoryId);
      return category.name;
    } catch (e) { return 'Category'; }
  }

  void _setError(String msg) {
    _errorMessage = msg.replaceAll("Exception: ", "");
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _socketStatusSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _flashcardsSubscription?.cancel();
    super.dispose();
  }
}