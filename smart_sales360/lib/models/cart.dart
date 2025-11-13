import 'product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final String price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      product: Product.fromJson({
        'id': json['producto_id'],
        'nombre': json['nombre_producto'],
        'sku': '',
        'codigo_barras': '',
        'descripcion': '',
        'categoria_id': 0,
        'precio_costo': '0',
        'precio_venta': json['price'],
        'stock_actual': 0,
        'stock_minimo': 0,
        'activo': true,
      }),
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? '0.00',
    );
  }

  double get subtotal {
    return (double.tryParse(price) ?? 0.0) * quantity;
  }
}

class Cart {
  final String id;
  final int? usuarioId;
  final String status;
  final List<CartItem> items;
  final String total;
  final DateTime createdAt;

  Cart({
    required this.id,
    this.usuarioId,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Cart(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuario_id'],
      status: json['status'] ?? 'open',
      items: items,
      total: json['total']?.toString() ?? '0.00',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  double get totalDouble {
    return double.tryParse(total) ?? 0.0;
  }

  int get itemsCount => items.length;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
