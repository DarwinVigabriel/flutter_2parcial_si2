import 'package:flutter/material.dart';
import '../services/stripe_service.dart';
import '../services/orden_service.dart';

class StripeProvider with ChangeNotifier {
  final StripeService _stripeService = StripeService();
  final OrdenService _ordenService = OrdenService();

  bool _procesando = false;
  String? _error;
  bool _pagoCorrecto = false;
  int _reintentos = 0;
  static const int maxReintentos = 3;

  // Getters
  bool get procesando => _procesando;
  String? get error => _error;
  bool get pagoCorrecto => _pagoCorrecto;
  int get reintentos => _reintentos;
  bool get puedeReintentar => _reintentos < maxReintentos && !_pagoCorrecto;

  /// Inicializar Stripe
  Future<void> inicializar() async {
    try {
      await StripeService.inicializarStripe();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Procesar pago con Payment Sheet
  Future<bool> procesarPagoConPaymentSheet({
    required String ordenId,
    required String email,
    required String nombre,
    required double monto,
  }) async {
    _procesando = true;
    _error = null;
    _pagoCorrecto = false;
    notifyListeners();

    try {
      // Obtener client secret del backend
      final checkoutData = await _ordenService.procesarCheckout(ordenId);
      final clientSecret = checkoutData['client_secret'] as String?;

      if (clientSecret == null) {
        throw Exception('No se recibió client secret del servidor');
      }

      // Presentar Payment Sheet
      final exitoso = await _stripeService.presentarPaymentSheet(
        clientSecret: clientSecret,
        email: email,
        nombre: nombre,
        monto: monto,
      );

      if (exitoso) {
        _pagoCorrecto = true;

        // Confirmar pago en el backend
        await _ordenService.confirmarPago(
          ordenId: ordenId,
          metodoPago: 'tarjeta',
          stripePaymentIntentId: clientSecret,
        );
      } else {
        throw Exception('El usuario canceló el pago o fue rechazado');
      }

      _procesando = false;
      _reintentos = 0;
      notifyListeners();
      return exitoso;
    } catch (e) {
      _error = e.toString();
      _pagoCorrecto = false;
      _procesando = false;
      notifyListeners();
      return false;
    }
  }

  /// Reintentar pago
  Future<bool> reintentarPago({
    required String ordenId,
    required String email,
    required String nombre,
    required double monto,
  }) async {
    if (_reintentos >= maxReintentos) {
      _error =
          'Número máximo de reintentos alcanzado ($maxReintentos). Contacta a soporte.';
      notifyListeners();
      return false;
    }

    _reintentos++;
    _pagoCorrecto = false;
    _error = null;

    return procesarPagoConPaymentSheet(
      ordenId: ordenId,
      email: email,
      nombre: nombre,
      monto: monto,
    );
  }

  /// Limpiar estado
  void limpiarEstado() {
    _error = null;
    _pagoCorrecto = false;
    _procesando = false;
    _reintentos = 0;
    notifyListeners();
  }
}
