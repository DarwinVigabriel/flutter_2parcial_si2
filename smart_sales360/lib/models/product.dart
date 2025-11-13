class Product {
  final int id;
  final String nombre;
  final String sku;
  final String codigoBarras;
  final String descripcion;
  final int categoriaId;
  final String precioCosto;
  final String precioVenta;
  final int stockActual;
  final int stockMinimo;
  final bool activo;

  Product({
    required this.id,
    required this.nombre,
    required this.sku,
    required this.codigoBarras,
    required this.descripcion,
    required this.categoriaId,
    required this.precioCosto,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.activo,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      sku: json['sku'] ?? '',
      codigoBarras: json['codigo_barras'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoriaId: json['categoria_id'] ?? 0,
      precioCosto: json['precio_costo']?.toString() ?? '0.00',
      precioVenta: json['precio_venta']?.toString() ?? '0.00',
      stockActual: json['stock_actual'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 0,
      activo: json['activo'] ?? true,
    );
  }

  double get priceSaleDouble {
    return double.tryParse(precioVenta) ?? 0.0;
  }

  bool get hasStock => stockActual > 0;
  bool get lowStock => stockActual <= stockMinimo;
}
