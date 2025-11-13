import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/index.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late StorageService _storage;

  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  Future<void> init() async {
    _storage = StorageService();
    await _storage.init();
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final token = _storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // CU7: Login
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authLogin}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'device_info': 'Flutter Mobile App',
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResp = LoginResponse.fromJson(data);
        await _storage.saveToken(loginResp.token);
        return loginResp;
      } else {
        throw Exception('Error en autenticación');
      }
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  // CU8: Get Products
  Future<List<Product>> getProducts({String? search, String? ordering}) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.products}';
      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

      if (queryParams.isNotEmpty) {
        url +=
            '?' +
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((p) => Product.fromJson(p)).toList();
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CU10: Lookup by Barcode
  Future<Product> lookupByBarcode(String barcode) async {
    try {
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.productsByBarcode}?barcode=$barcode';
      final headers = await _getHeaders();

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Producto no encontrado');
      }
    } catch (e) {
      throw Exception('Error al escanear: $e');
    }
  }

  // CU9: Create Cart
  Future<Cart> createCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carts}'),
            headers: headers,
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final cart = Cart.fromJson(data);
        await _storage.saveCartId(cart.id);
        return cart;
      } else {
        throw Exception('Error al crear carrito');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CU9: Add Item to Cart
  Future<Cart> addItemToCart(String cartId, int productId, int quantity) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.carts}$cartId/add_item/';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({'producto_id': productId, 'quantity': quantity}),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else {
        throw Exception('Error al agregar producto');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CU9: Update Item Quantity
  Future<Cart> updateItemQuantity(
    String cartId,
    int itemId,
    int quantity,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.carts}$cartId/update_item/';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({'item_id': itemId, 'quantity': quantity}),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else {
        throw Exception('Error al actualizar cantidad');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CU9: Remove Item from Cart
  Future<Cart> removeItemFromCart(String cartId, int itemId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.carts}$cartId/remove_item/';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({'item_id': itemId}),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else {
        throw Exception('Error al eliminar producto');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CU9: Clear Cart
  Future<Cart> clearCart(String cartId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.carts}$cartId/clear/';

      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else {
        throw Exception('Error al vaciar carrito');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.logout();
  }
}
