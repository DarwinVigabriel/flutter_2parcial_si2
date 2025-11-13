import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io' show Platform;

class StripeService {
  // Clave publicable de Stripe (modo test)
  static const String stripePublishableKey =
      'pk_test_51Nxxxxxxxxxxxxxxxxxxxxxxx';

  // Este se obtiene del backend
  late String _stripeClientSecret;

  /// Inicializar Stripe
  static Future<void> inicializarStripe() async {
    Stripe.publishableKey = stripePublishableKey;

    // Verificar que la plataforma sea soportada
    if (Platform.isAndroid) {
      // Configuración adicional para Android si es necesaria
    } else if (Platform.isIOS) {
      // Configuración adicional para iOS si es necesaria
    }

    await Stripe.instance.applySettings();
  }

  /// Procesar pago con Payment Intent
  Future<bool> procesarPago({
    required String clientSecret,
    required String email,
    required String nombre,
  }) async {
    try {
      _stripeClientSecret = clientSecret;

      // Crear Payment Method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(email: email, name: nombre),
          ),
        ),
      );

      if (paymentMethod.id.isEmpty) {
        throw Exception('No se pudo crear el método de pago');
      }

      // Confirmar Payment Intent
      await Stripe.instance.confirmPaymentSheetPayment(
        clientSecret: clientSecret,
      );

      return true;
    } on StripeException catch (e) {
      throw Exception('Error de Stripe: ${e.error.localizedMessage}');
    } catch (e) {
      throw Exception('Error procesando pago: $e');
    }
  }

  /// Presentar Payment Sheet (formulario de pago)
  Future<bool> presentarPaymentSheet({
    required String clientSecret,
    required String email,
    required String nombre,
    required double monto,
  }) async {
    try {
      // Configurar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Smart Sales 360',
          customFlow: false,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: 'USD',
          ),
          style: ThemeMode.system,
          billingDetailsCollectionConfiguration:
              BillingDetailsCollectionConfiguration(
                name: CollectionMode.always,
                email: CollectionMode.always,
                phone: CollectionMode.never,
                address: CollectionMode.never,
              ),
          returnURL: 'flutterstripe://payment-return',
          customColor: null,
        ),
      );

      // Presentar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Cancelled) {
        throw Exception('Pago cancelado');
      }
      throw Exception('Error: ${e.error.localizedMessage}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Crear sesión de Stripe Checkout (alternativa web)
  Future<String?> crearSessionCheckout({
    required String ordenId,
    required double monto,
  }) async {
    try {
      // Esta llamada iría a tu backend
      // El backend crearía la sesión y retornaría el session_id
      // return await backendService.crearCheckoutSession(ordenId, monto);
      return null;
    } catch (e) {
      throw Exception('Error creando sesión: $e');
    }
  }

  /// Manejar resultado del pago
  static Future<Map<String, dynamic>> obtenerResultadoPago(
    String clientSecret,
  ) async {
    try {
      final paymentIntentClientSecret = clientSecret;
      // Aquí normalmente verificarías el estado del pago
      return {'success': true, 'clientSecret': paymentIntentClientSecret};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Cancelar pago
  static Future<void> cancelarPago() async {
    // Lógica para cancelar el pago si es necesario
  }
}
