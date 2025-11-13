import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdenService {
  static const String baseUrl = 'http://10.0.2.3:8000/api/sales';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// CU17: Crear orden desde carrito
  Future<Map<String, dynamic>> crearOrdenDesdeCarrito(String carritoId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: headers,
        body: jsonEncode({'carrito_id': carritoId}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear orden: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en crearOrdenDesdeCarrito: $e');
    }
  }

  /// CU17: Procesar checkout con Stripe
  Future<Map<String, dynamic>> procesarCheckout(String ordenId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$ordenId/checkout/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al procesar checkout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en procesarCheckout: $e');
    }
  }

  /// CU17: Confirmar pago completado
  Future<Map<String, dynamic>> confirmarPago({
    required String ordenId,
    required String metodoPago,
    String? stripePaymentIntentId,
  }) async {
    try {
      final headers = await getHeaders();
      final body = {
        'metodo_pago': metodoPago,
        if (stripePaymentIntentId != null)
          'stripe_payment_intent_id': stripePaymentIntentId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders/$ordenId/confirmar_pago/'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al confirmar pago: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en confirmarPago: $e');
    }
  }

  /// CU18: Listar órdenes del usuario
  Future<List<dynamic>> listarOrdenes({
    String? estado,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final headers = await getHeaders();
      String url = '$baseUrl/ordenes-historial/';

      final params = <String, String>{};
      if (estado != null) params['estado'] = estado;
      if (fechaInicio != null) params['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) params['fecha_fin'] = fechaFin;

      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al listar órdenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en listarOrdenes: $e');
    }
  }

  /// CU18: Obtener estadísticas de órdenes
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ordenes-historial/estadisticas-resumen/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerEstadisticas: $e');
    }
  }

  /// CU18: Obtener órdenes por estado
  Future<Map<String, dynamic>> obtenerOrdenesPorEstado(String estado) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ordenes-historial/por-estado/?estado=$estado'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener órdenes por estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerOrdenesPorEstado: $e');
    }
  }

  /// CU19: Obtener resumen del dashboard
  Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-mobile/resumen/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener resumen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerResumenDashboard: $e');
    }
  }

  /// CU19: Obtener últimas compras
  Future<Map<String, dynamic>> obtenerUltimasCompras() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-mobile/ultimas-compras/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener últimas compras: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerUltimasCompras: $e');
    }
  }

  /// CU19: Obtener estadísticas del dashboard
  Future<Map<String, dynamic>> obtenerEstadisticasDashboard() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-mobile/estadisticas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerEstadisticasDashboard: $e');
    }
  }

  /// CU19: Obtener alertas
  Future<Map<String, dynamic>> obtenerAlertas() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-mobile/alertas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener alertas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerAlertas: $e');
    }
  }

  /// CU20: Listar notificaciones
  Future<List<dynamic>> listarNotificaciones() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notificaciones-push/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al listar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en listarNotificaciones: $e');
    }
  }

  /// CU20: Obtener notificaciones sin leer
  Future<Map<String, dynamic>> obtenerNotificacionesSinLeer() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notificaciones-push/sin-leer/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener notificaciones sin leer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerNotificacionesSinLeer: $e');
    }
  }

  /// CU20: Marcar notificación como entregada
  Future<Map<String, dynamic>> marcarNotificacionEntregada(int notificacionId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notificaciones-push/$notificacionId/marcar-entregada/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al marcar notificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en marcarNotificacionEntregada: $e');
    }
  }

  /// CU20: Limpiar notificaciones leídas
  Future<Map<String, dynamic>> limpiarNotificacionesLeidas() async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notificaciones-push/limpiar-leidas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al limpiar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en limpiarNotificacionesLeidas: $e');
    }
  }
}
