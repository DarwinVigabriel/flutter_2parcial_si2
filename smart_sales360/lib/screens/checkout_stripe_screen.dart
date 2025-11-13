import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orden_provider.dart';
import '../providers/stripe_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutStripeScreen extends StatefulWidget {
  final String carritoId;

  const CheckoutStripeScreen({Key? key, required this.carritoId})
    : super(key: key);

  @override
  State<CheckoutStripeScreen> createState() => _CheckoutStripeScreenState();
}

class _CheckoutStripeScreenState extends State<CheckoutStripeScreen> {
  late OrdenProvider _ordenProvider;
  late StripeProvider _stripeProvider;

  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
    _stripeProvider = Provider.of<StripeProvider>(context, listen: false);

    // Inicializar Stripe
    _stripeProvider.inicializar();

    // Crear orden
    _crearOrden();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _crearOrden() async {
    final exitoso = await _ordenProvider.crearOrden(widget.carritoId);
    if (!exitoso && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${_ordenProvider.error}')));
    }
  }

  Future<void> _procesarPago() async {
    // Validar campos
    if (_emailController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final orden = _ordenProvider.ordenSeleccionada;
    if (orden == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: No hay orden')));
      return;
    }

    // Procesar pago
    final exitoso = await _stripeProvider.procesarPagoConPaymentSheet(
      ordenId: orden['id'],
      email: _emailController.text,
      nombre: _nombreController.text,
      monto: double.parse(orden['total'].toString()),
    );

    if (exitoso && mounted) {
      // Mostrar diálogo de éxito
      _mostrarDialogoExito(context, orden);
    } else if (mounted && _stripeProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${_stripeProvider.error}')),
      );
    }
  }

  void _mostrarDialogoExito(BuildContext context, dynamic orden) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('¡Pago Exitoso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Orden #${orden['numero_orden']} confirmada'),
            const SizedBox(height: 12),
            Text(
              'Total pagado: \$${orden['total']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recibirás una confirmación por correo electrónico',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Volver a la pantalla anterior y limpiar el carrito
              Navigator.pop(context);
              // Opcionalmente, navegar al historial de órdenes
              // Navigator.pushNamed(context, '/historial-ordenes');
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Seguro'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Consumer3<OrdenProvider, StripeProvider, CartProvider>(
        builder: (context, ordenProvider, stripeProvider, cartProvider, _) {
          if (ordenProvider.cargando || stripeProvider.procesando) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando...'),
                ],
              ),
            );
          }

          final orden = ordenProvider.ordenSeleccionada;
          if (orden == null) {
            return const Center(child: Text('No se pudo cargar la orden'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de Orden
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen de tu Orden',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildResumenFila(
                          'Orden #',
                          orden['numero_orden'] ?? 'N/A',
                        ),
                        _buildResumenFila(
                          'Subtotal',
                          '\$${orden['subtotal'] ?? 0.00}',
                        ),
                        _buildResumenFila(
                          'Impuesto',
                          '\$${orden['impuesto'] ?? 0.00}',
                        ),
                        const Divider(height: 16),
                        _buildResumenFila(
                          'Total a Pagar',
                          '\$${orden['total'] ?? 0.00}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Items de la Orden
                Text(
                  'Artículos (${(orden['items'] as List?)?.length ?? 0})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (orden['items'] != null &&
                    (orden['items'] as List).isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (orden['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = orden['items'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['producto_detail']?['nombre'] ?? 'Producto'} x${item['cantidad']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('\$${item['subtotal']}'),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // Formulario de datos
                Text(
                  'Información de Contacto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    hintText: 'Juan Pérez',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'juan@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 24),

                // Logo de Stripe
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Pago seguro con Stripe',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Pagar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _procesarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Pagar Ahora',
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(height: 16),

                // Aviso de seguridad
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tus datos de pago están protegidos con encriptación SSL. Smart Sales 360 nunca accede a tus datos de tarjeta.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumenFila(
    String etiqueta,
    String valor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isBold ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
