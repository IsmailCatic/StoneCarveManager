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
      debugPrint('[FavoritesProvider] 🔄 Loading favorites...');

      // First, load from local cache for instant UI
      await _loadFromLocalStorage();
      _isInitialized = true;
      notifyListeners();

      // Then sync with backend if authenticated
      if (AuthProvider.isAuthenticated()) {
        debugPrint(
          '[FavoritesProvider] ✅ Authenticated - syncing with backend',
        );
        // Don't await - let it run in background
        _fetchFromBackend()
            .then((_) {
              debugPrint('[FavoritesProvider] ✅ Background sync completed');
            })
            .catchError((e) {
              debugPrint('[FavoritesProvider] ❌ Background sync failed: $e');
            });
      } else {
        debugPrint(
          '[FavoritesProvider] ⚠️ Not authenticated, using local cache only',
        );
      }
    } catch (e) {
      debugPrint('[FavoritesProvider] ❌ Error loading favorites: $e');
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
        debugPrint(
          '[FavoritesProvider] Loaded ${_favoriteProductIds.length} favorites from cache',
        );
      } else {
        debugPrint('[FavoritesProvider] No cached favorites found');
      }
    } catch (e) {
      debugPrint('[FavoritesProvider] Error loading from cache: $e');
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
      debugPrint(
        '[FavoritesProvider] Saved ${idsToSave.length} favorites to cache',
      );
    } catch (e) {
      debugPrint('[FavoritesProvider] Error saving to cache: $e');
    }
  }

  /// Fetch favorites from backend
  Future<void> _fetchFromBackend() async {
    try {
      // Use /ids endpoint to get just the product IDs
      final url = '${BaseProvider.baseUrl}/api/Favorite/ids';
      debugPrint('[FavoritesProvider] Fetching from backend: $url');

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

          debugPrint(
            '[FavoritesProvider] Synced ${_favoriteProductIds.length} favorites from backend',
          );
        } else {
          debugPrint('[FavoritesProvider] Backend favorites match local cache');
        }

        _lastError = null;
      } else if (response.statusCode == 401) {
        debugPrint('[FavoritesProvider] Unauthorized, using local cache');
        _lastError = 'Not authenticated';
      } else {
        debugPrint(
          '[FavoritesProvider] Backend error ${response.statusCode}, using cache',
        );
        _lastError = 'Backend error: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('[FavoritesProvider] Network error, using cache: $e');
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
            debugPrint('[FavoritesProvider] Backend sync failed: $error');
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
      debugPrint('[FavoritesProvider] Sync error: $e');
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
    debugPrint(
      '[FavoritesProvider] Added ${newIds.length} products to favorites',
    );

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

    debugPrint(
      '[FavoritesProvider] Removed ${productIds.length} products from favorites',
    );

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

    debugPrint('[FavoritesProvider] Cleared all $count favorites');

    // Sync with backend
    if (AuthProvider.isAuthenticated()) {
      try {
        final url = '${BaseProvider.baseUrl}/api/Favorite';
        final response = await http
            .delete(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          debugPrint('[FavoritesProvider] Backend clear successful');
          _lastError = null;
        } else {
          throw Exception('Backend returned ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('[FavoritesProvider] Backend clear failed, reverting: $e');

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
      debugPrint('[FavoritesProvider] Sync already in progress');
      return false;
    }

    if (!AuthProvider.isAuthenticated()) {
      debugPrint('[FavoritesProvider] Cannot sync - not authenticated');
      return false;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final url = '${BaseProvider.baseUrl}/api/Favorite/sync';
      final localIds = _favoriteProductIds.toList();

      debugPrint(
        '[FavoritesProvider] Syncing ${localIds.length} local favorites with backend',
      );

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
        debugPrint('[FavoritesProvider] Sync successful: ${result['message']}');
        debugPrint(
          '[FavoritesProvider] Added: ${result['added']}, Removed: ${result['removed']}',
        );

        // Server returns the synchronized list
        final serverFavorites = List<int>.from(
          result['serverFavorites'] ?? localIds,
        );

        // Update local state with server truth
        _favoriteProductIds.clear();
        _favoriteProductIds.addAll(serverFavorites);

        await _saveToLocalStorage();
        _lastError = null;

        debugPrint(
          '[FavoritesProvider] Final count: ${_favoriteProductIds.length}',
        );

        return true;
      } else {
        throw Exception('Sync failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FavoritesProvider] Sync error: $e');
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
      debugPrint('[FavoritesProvider] Refreshed from backend');
    } catch (e) {
      debugPrint('[FavoritesProvider] Refresh failed: $e');
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
