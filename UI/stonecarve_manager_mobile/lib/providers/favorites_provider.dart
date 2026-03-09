import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

/// FavoritesProvider manages user's favorite products with backend sync
///
/// Features:
/// - Backend API integration with offline support
/// - Optimistic UI updates for instant feedback
/// - Persistent storage using SharedPreferences as cache
/// - Automatic sync with backend
/// - Graceful offline degradation
///
/// Best Practices Implementation:
/// - Offline-first strategy: works without internet
/// - ChangeNotifier for reactive state management
/// - Optimistic updates: UI responds immediately
/// - Backend sync: keeps data consistent across devices
/// - Local cache: SharedPreferences for offline access
/// - Error handling and logging
class FavoritesProvider with ChangeNotifier {
  static const String _storageKey = 'favorite_product_ids';

  // Set for O(1) lookup performance
  final Set<int> _favoriteProductIds = {};

  // State tracking
  bool _isInitialized = false;
  bool _isSyncing = false;
  String? _lastError;

  /// Get all favorite product IDs
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteProductIds);

  /// Check if provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Check if currently syncing with backend
  bool get isSyncing => _isSyncing;

  /// Get last error message
  String? get lastError => _lastError;

  /// Get count of favorite products
  int get favoriteCount => _favoriteProductIds.length;

  /// Check if a product is in favorites
  /// Time complexity: O(1)
  bool isFavorite(int? productId) {
    if (productId == null) return false;
    return _favoriteProductIds.contains(productId);
  }

  /// Initialize favorites - tries backend first, falls back to local cache
  /// Should be called AFTER successful login
  Future<void> loadFavorites() async {
    try {

      // First, load from local cache for instant UI
      await _loadFromLocalStorage();
      _isInitialized = true;
      notifyListeners();

      // Then sync with backend if authenticated
      if (AuthProvider.isAuthenticated()) {
        // Don't await - let it run in background
        _fetchFromBackend()
            .then((_) {
            })
            .catchError((e) {
            });
      } else {
      }
    } catch (e) {
      _lastError = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Load favorites from local storage (cache)
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList(_storageKey);

      if (savedIds != null) {
        _favoriteProductIds.clear();
        _favoriteProductIds.addAll(
          savedIds.map((id) => int.parse(id)).toList(),
        );
      } else {
      }
    } catch (e) {
    }
  }

  /// Save favorites to local storage (cache)
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> idsToSave = _favoriteProductIds
          .map((id) => id.toString())
          .toList();

      await prefs.setStringList(_storageKey, idsToSave);
    } catch (e) {
    }
  }

  /// Fetch favorites from backend
  Future<void> _fetchFromBackend() async {
    try {
      // Use /ids endpoint to get just the product IDs
      final url = '${BaseProvider.baseUrl}/api/Favorite/ids';

      final response = await http
          .get(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> serverIds = json.decode(response.body);
        final newFavorites = serverIds.map((id) => id as int).toSet();

        // Check if there are changes
        if (!setEquals(_favoriteProductIds, newFavorites)) {
          _favoriteProductIds.clear();
          _favoriteProductIds.addAll(newFavorites);
          await _saveToLocalStorage();
          notifyListeners();

        } else {
        }

        _lastError = null;
      } else if (response.statusCode == 401) {
        _lastError = 'Not authenticated';
      } else {
        _lastError = 'Backend error: ${response.statusCode}';
      }
    } catch (e) {
      _lastError = 'Offline mode';
      // Continue using local cache
    }
  }

  /// Toggle favorite status with backend sync
  /// Uses optimistic UI update for instant feedback
  /// Returns true if product was added to favorites, false if removed
  Future<bool> toggleFavorite(int? productId) async {
    if (productId == null) return false;

    // Optimistic UI update - change immediately for instant feedback
    final wasInFavorites = _favoriteProductIds.contains(productId);
    final isNowFavorite = !wasInFavorites;

    if (isNowFavorite) {
      _favoriteProductIds.add(productId);
    } else {
      _favoriteProductIds.remove(productId);
    }

    // Update UI immediately
    notifyListeners();

    // Save to local cache
    await _saveToLocalStorage();

    // Sync with backend in background
    if (AuthProvider.isAuthenticated()) {
      // Don't revert on error - keep local change for offline-first approach
      _syncToggleWithBackend(productId, isNowFavorite)
          .then((_) {
            _lastError = null;
          })
          .catchError((error) {
            // Log error but DON'T revert - offline-first approach
            _lastError = 'Saved locally (sync failed)';
          });
    } else {
      _lastError = 'Saved locally only (not authenticated)';
    }

    return isNowFavorite;
  }

  /// Sync toggle operation with backend
  Future<void> _syncToggleWithBackend(int productId, bool shouldAdd) async {
    try {
      final url = '${BaseProvider.baseUrl}/api/Favorite/$productId';
      final headers = AuthProvider.getAuthHeaders();

      final response = shouldAdd
          ? await http
                .post(Uri.parse(url), headers: headers)
                .timeout(const Duration(seconds: 10))
          : await http
                .delete(Uri.parse(url), headers: headers)
                .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _lastError = null;
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Add a product to favorites
  /// Returns true if product was added, false if already in favorites
  Future<bool> addFavorite(int? productId) async {
    if (productId == null) return false;

    if (_favoriteProductIds.contains(productId)) {
      return false; // Already in favorites
    }

    return await toggleFavorite(productId);
  }

  /// Remove a product from favorites
  /// Returns true if product was removed, false if not in favorites
  Future<bool> removeFavorite(int? productId) async {
    if (productId == null) return false;

    if (!_favoriteProductIds.contains(productId)) {
      return false; // Not in favorites
    }

    return !(await toggleFavorite(productId));
  }

  /// Add multiple products to favorites at once
  Future<void> addMultipleFavorites(List<int> productIds) async {
    if (productIds.isEmpty) return;

    final newIds = productIds.where((id) => !_favoriteProductIds.contains(id));

    _favoriteProductIds.addAll(newIds);

    notifyListeners();
    await _saveToLocalStorage();

    // Sync with backend
    if (AuthProvider.isAuthenticated()) {
      syncWithBackend();
    }
  }

  /// Remove multiple products from favorites at once
  Future<void> removeMultipleFavorites(List<int> productIds) async {
    if (productIds.isEmpty) return;

    for (final id in productIds) {
      _favoriteProductIds.remove(id);
    }


    notifyListeners();
    await _saveToLocalStorage();

    // Sync with backend
    if (AuthProvider.isAuthenticated()) {
      syncWithBackend();
    }
  }

  /// Clear all favorites with backend sync
  Future<void> clearAllFavorites() async {
    final count = _favoriteProductIds.length;

    // Backup current state in case we need to revert
    final backup = Set<int>.from(_favoriteProductIds);

    // Optimistic update
    _favoriteProductIds.clear();
    notifyListeners();
    await _saveToLocalStorage();


    // Sync with backend
    if (AuthProvider.isAuthenticated()) {
      try {
        final url = '${BaseProvider.baseUrl}/api/Favorite';
        final response = await http
            .delete(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _lastError = null;
        } else {
          throw Exception('Backend returned ${response.statusCode}');
        }
      } catch (e) {

        // Revert on failure
        _favoriteProductIds.addAll(backup);
        notifyListeners();
        await _saveToLocalStorage();

        _lastError = 'Failed to clear on server';
        rethrow;
      }
    }
  }

  /// Sync local favorites with backend (two-way sync)
  /// Should be called after login or when coming back online
  Future<bool> syncWithBackend() async {
    if (_isSyncing) {
      return false;
    }

    if (!AuthProvider.isAuthenticated()) {
      return false;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final url = '${BaseProvider.baseUrl}/api/Favorite/sync';
      final localIds = _favoriteProductIds.toList();


      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              ...AuthProvider.getAuthHeaders(),
              'Content-Type': 'application/json',
            },
            body: json.encode(localIds),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // Server returns the synchronized list
        final serverFavorites = List<int>.from(
          result['serverFavorites'] ?? localIds,
        );

        // Update local state with server truth
        _favoriteProductIds.clear();
        _favoriteProductIds.addAll(serverFavorites);

        await _saveToLocalStorage();
        _lastError = null;


        return true;
      } else {
        throw Exception('Sync failed: ${response.statusCode}');
      }
    } catch (e) {
      _lastError = 'Sync failed: $e';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Force refresh from backend (overwrites local)
  /// Use when you want to discard local changes
  Future<void> refreshFromBackend() async {
    if (!AuthProvider.isAuthenticated()) return;

    try {
      await _fetchFromBackend();
    } catch (e) {
      _lastError = 'Refresh failed';
    }
  }

  /// Check if multiple products are in favorites
  /// Returns a map of productId -> isFavorite
  Map<int, bool> checkMultipleFavorites(List<int> productIds) {
    return {for (final id in productIds) id: _favoriteProductIds.contains(id)};
  }

  /// Filter a list of products to only include favorites
  List<Product> filterFavorites(List<Product> products) {
    return products
        .where((product) => product.id != null && isFavorite(product.id))
        .toList();
  }
}
