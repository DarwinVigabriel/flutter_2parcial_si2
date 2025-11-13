import 'package:flutter/material.dart';
import '../services/orden_service.dart';

class OrdenProvider with ChangeNotifier {
  final OrdenService _ordenService = OrdenService();

  // Estado de órdenes
  List<dynamic> _ordenes = [];
  Map<String, dynamic>? _ordenSeleccionada;
  Map<String, dynamic>? _resumenDashboard;
  Map<String, dynamic>? _estadisticasDashboard;
  List<dynamic> _alertas = [];
  List<dynamic> _notificaciones = [];

  bool _cargando = false;
  String? _error;

  // Getters
  List<dynamic> get ordenes => _ordenes;
  Map<String, dynamic>? get ordenSeleccionada => _ordenSeleccionada;
  Map<String, dynamic>? get resumenDashboard => _resumenDashboard;
  Map<String, dynamic>? get estadisticasDashboard => _estadisticasDashboard;
  List<dynamic> get alertas => _alertas;
  List<dynamic> get notificaciones => _notificaciones;
  bool get cargando => _cargando;
  String? get error => _error;

  // Setters
  set ordenSeleccionada(Map<String, dynamic>? orden) {
    _ordenSeleccionada = orden;
    notifyListeners();
  }

  /// CU17: Crear orden desde carrito
  Future<bool> crearOrden(String carritoId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _ordenService.crearOrdenDesdeCarrito(carritoId);
      _ordenSeleccionada = resultado;
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU17: Procesar checkout con Stripe
  Future<Map<String, dynamic>?> procesarCheckout(String ordenId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _ordenService.procesarCheckout(ordenId);
      _cargando = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return null;
    }
  }

  /// CU17: Confirmar pago
  Future<bool> confirmarPago({
    required String ordenId,
    required String metodoPago,
    String? stripePaymentIntentId,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _ordenService.confirmarPago(
        ordenId: ordenId,
        metodoPago: metodoPago,
        stripePaymentIntentId: stripePaymentIntentId,
      );
      _ordenSeleccionada = resultado;
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU18: Listar órdenes
  Future<bool> cargarOrdenes({
    String? estado,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _ordenes = await _ordenService.listarOrdenes(
        estado: estado,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU18: Obtener estadísticas
  Future<bool> cargarEstadisticas() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _estadisticasDashboard = await _ordenService.obtenerEstadisticas();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU19: Cargar resumen dashboard
  Future<bool> cargarResumenDashboard() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _resumenDashboard = await _ordenService.obtenerResumenDashboard();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU19: Cargar alertas
  Future<bool> cargarAlertas() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _ordenService.obtenerAlertas();
      _alertas = resultado['alertas'] ?? [];
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU20: Cargar notificaciones
  Future<bool> cargarNotificaciones() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _notificaciones = await _ordenService.listarNotificaciones();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// CU20: Marcar notificación como entregada
  Future<bool> marcarNotificacionEntregada(int notificacionId) async {
    try {
      await _ordenService.marcarNotificacionEntregada(notificacionId);
      // Recargar notificaciones
      await cargarNotificaciones();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Limpiar errores
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
