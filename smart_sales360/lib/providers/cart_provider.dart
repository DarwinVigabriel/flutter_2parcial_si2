import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  // Getters
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCart => _cart != null;

  // CU9: Create Cart
  Future<bool> createCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _apiService.createCart();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CU9: Add Item
  Future<bool> addItem(int productId, int quantity) async {
    if (_cart == null) {
      _error = 'No hay carrito activo';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _apiService.addItemToCart(_cart!.id, productId, quantity);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CU9: Update Item
  Future<bool> updateItem(int itemId, int quantity) async {
    if (_cart == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _apiService.updateItemQuantity(_cart!.id, itemId, quantity);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CU9: Remove Item
  Future<bool> removeItem(int itemId) async {
    if (_cart == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _apiService.removeItemFromCart(_cart!.id, itemId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CU9: Clear Cart
  Future<bool> clearCart() async {
    if (_cart == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _apiService.clearCart(_cart!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
