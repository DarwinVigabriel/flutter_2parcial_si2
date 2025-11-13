import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_colors.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _barcodeController = TextEditingController();
  late MobileScannerController cameraController;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(String barcode) async {
    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.lookupByBarcode(barcode);

    if (success && mounted) {
      _showProductDialog();
    }
  }

  void _showProductDialog() {
    final product = context.read<ProductProvider>().selectedProduct;
    if (product == null) return;

    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Producto Escaneado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                product.nombre,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'SKU: ${product.sku}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                'Código: ${product.codigoBarras}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precio: \$${product.precioVenta}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Stock: ${product.stockActual}',
                        style: TextStyle(
                          color: product.hasStock
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: quantity > 1
                                ? AppColors.secondary
                                : AppColors.border,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Center(child: Text(quantity.toString())),
                        ),
                        GestureDetector(
                          onTap: quantity < product.stockActual
                              ? () => setState(() => quantity++)
                              : null,
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: quantity < product.stockActual
                                ? AppColors.secondary
                                : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _barcodeController.clear();
                context.read<ProductProvider>().clearSelected();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: product.hasStock
                  ? () async {
                      final cartProvider = context.read<CartProvider>();
                      final success = await cartProvider.addItem(
                        product.id,
                        quantity,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        _barcodeController.clear();
                        context.read<ProductProvider>().clearSelected();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Producto agregado al carrito'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: product.hasStock
                    ? AppColors.primary
                    : AppColors.border,
              ),
              child: Text('Agregar al Carrito'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Escanear Código'),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_manualMode ? Icons.qr_code_scanner : Icons.edit),
            onPressed: () {
              setState(() => _manualMode = !_manualMode);
            },
          ),
        ],
      ),
      body: _manualMode ? _buildManualInput() : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first.rawValue;
                if (barcode != null) {
                  _handleBarcode(barcode);
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Error al acceder a la cámara',
                      style: TextStyle(color: AppColors.error, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.black87,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Apunta a un código de barras para escanearlo',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualInput() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresa el código manualmente:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _barcodeController,
            decoration: InputDecoration(
              hintText: 'Código de barras...',
              prefixIcon: Icon(
                Icons.barcode_reader,
                color: AppColors.secondary,
              ),
              suffixIcon: _barcodeController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _barcodeController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _handleBarcode(value);
              }
            },
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _barcodeController.text.isNotEmpty
                  ? () => _handleBarcode(_barcodeController.text)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.error != null) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
