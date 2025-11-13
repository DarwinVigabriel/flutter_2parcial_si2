import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orden_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final String carritoId;

  const CheckoutScreen({
    Key? key,
    required this.carritoId,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late OrdenProvider _ordenProvider;
  late CartProvider _cartProvider;

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _crearOrden();
  }

  Future<void> _crearOrden() async {
    final exitoso = await _ordenProvider.crearOrden(widget.carritoId);
    if (!exitoso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${_ordenProvider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Consumer<OrdenProvider>(
        builder: (context, ordenProvider, _) {
          if (ordenProvider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordenProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${ordenProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final orden = ordenProvider.ordenSeleccionada;
          if (orden == null) {
            return const Center(child: Text('No se pudo crear la orden'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de Orden
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen de Orden',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Orden #'),
                            Text(
                              orden['numero_orden'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\$${orden['subtotal'] ?? 0.00}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Impuesto:'),
                            Text('\$${orden['impuesto'] ?? 0.00}'),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${orden['total'] ?? 0.00}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Items de la Orden
                Text(
                  'Artículos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (orden['items'] != null && (orden['items'] as List).isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (orden['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = orden['items'][index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Cantidad
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item['cantidad']}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Información del producto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['producto_detail']?['nombre'] ?? 'Producto',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item['precio_unitario']} c/u',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Subtotal
                              Text(
                                '\$${item['subtotal']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Center(child: Text('No hay items')),

                const SizedBox(height: 32),

                // Botón de Proceder al Pago
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Aquí se integraría Stripe
                      // Por ahora, mostrar diálogo de confirmación
                      _mostrarDialogoConfirmacion(context, orden['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceder al Pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context, String ordenId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: const Text(
          '¿Estás seguro de que deseas proceder con el pago?\n\n'
          '(Integración con Stripe pendiente)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Aquí iría la integración con Stripe
              // Por ahora, confirmamos el pago manualmente
              final exitoso = await _ordenProvider.confirmarPago(
                ordenId: ordenId,
                metodoPago: 'tarjeta',
              );

              if (exitoso && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pago completado exitosamente')),
                );
                // Esperar un poco y volver
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
