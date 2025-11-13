class ApiConfig {
  // Cambiar según el ambiente
  static const String baseUrl = 'https://backend2parcialsi2-production.up.railway.app'; // Producción Railway
  // static const String baseUrl = 'http://192.168.0.4:8000'; // Desarrollo local

  // Endpoints
  static const String authLogin = '/api/auth/login/';
  static const String products = '/api/products/products/';
  static const String productsByBarcode =
      '/api/products/products/lookup_by_barcode/';
  static const String carts = '/api/sales/carts/';
  static const String cartAddItem = '/api/sales/carts/%s/add_item/';
  static const String cartRemoveItem = '/api/sales/carts/%s/remove_item/';
  static const String cartUpdateItem = '/api/sales/carts/%s/update_item/';
  static const String cartCheckout = '/api/sales/carts/%s/checkout/';
  static const String cartClear = '/api/sales/carts/%s/clear/';
  static const String ventasMovil = '/api/sales/ventas-movil/';
  static const String ventasHistorial = '/api/sales/ventas-movil/historial/';
  static const String notificaciones = '/api/sales/notificaciones/';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
