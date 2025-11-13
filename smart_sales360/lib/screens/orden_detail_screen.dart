import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/orden_provider.dart';
import '../config/app_colors.dart';

class OrdenDetailScreen extends StatefulWidget {
  final String ordenId;

  const OrdenDetailScreen({Key? key, required this.ordenId}) : super(key: key);

  @override
  State<OrdenDetailScreen> createState() => _OrdenDetailScreenState();
}

class _OrdenDetailScreenState extends State<OrdenDetailScreen> {
  late OrdenProvider _ordenProvider;

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return fecha;
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'pagada':
        return Colors.blue;
      case 'confirmada':
        return Colors.teal;
      case 'enviada':
        return Colors.purple;
      case 'entregada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'pagada':
        return Icons.check_circle;
      case 'confirmada':
        return Icons.verified;
      case 'enviada':
        return Icons.local_shipping;
      case 'entregada':
        return Icons.done_all;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Orden'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<OrdenProvider>(
        builder: (context, ordenProvider, _) {
          if (ordenProvider.cargando) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando orden...'),
                ],
              ),
            );
          }

          final orden = ordenProvider.ordenSeleccionada;
          if (orden == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('No se pudo cargar la orden'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final estado = orden['estado'] ?? 'pendiente';
          final items = (orden['items'] as List?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con número de orden y estado
                _buildEncabezado(orden, estado),
                const SizedBox(height: 24),

                // Información de Cantidades
                _buildResumenFinanciero(orden),
                const SizedBox(height: 24),

                // Estado y Fechas
                _buildEstadoYFechas(orden, estado),
                const SizedBox(height: 24),

                // Items de la orden
                _buildSeccionItems(items),
                const SizedBox(height: 24),

                // Información adicional
                _buildInformacionAdicional(orden),
                const SizedBox(height: 24),

                // Botones de acción
                _buildBotonesAccion(context, orden),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncabezado(Map<String, dynamic> orden, String estado) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              _getColorEstado(estado).withOpacity(0.1),
              _getColorEstado(estado).withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Orden #',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orden['numero_orden'] ??
                          orden['id']?.toString().substring(0, 8) ??
                          'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorEstado(estado),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconoEstado(estado),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        estado.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Creada: ${_formatearFecha(orden['created_at'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenFinanciero(Map<String, dynamic> orden) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Financiero',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFilaResumen('Subtotal', '\$${orden['subtotal'] ?? 0.00}'),
            const SizedBox(height: 12),
            _buildFilaResumen(
              'Impuesto (IVA)',
              '\$${orden['impuesto'] ?? 0.00}',
            ),
            const Divider(height: 24),
            _buildFilaResumen(
              'Total',
              '\$${orden['total'] ?? 0.00}',
              isBold: true,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaResumen(
    String label,
    String valor, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 18 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoYFechas(Map<String, dynamic> orden, String estado) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Entrega',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildItemTimeline(
              'Orden Creada',
              _formatearFecha(orden['created_at']),
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 12),
            if (orden['pagada_en'] != null)
              _buildItemTimeline(
                'Pagada',
                _formatearFecha(orden['pagada_en']),
                Icons.check_circle,
                Colors.green,
              ),
            if (orden['pagada_en'] == null && estado != 'pendiente')
              _buildItemTimeline(
                'Pagada',
                'Pendiente',
                Icons.schedule,
                Colors.orange,
              ),
            const SizedBox(height: 12),
            if (orden['entregada_en'] != null)
              _buildItemTimeline(
                'Entregada',
                _formatearFecha(orden['entregada_en']),
                Icons.check_circle,
                Colors.green,
              ),
            if (orden['entregada_en'] == null && estado != 'pendiente')
              _buildItemTimeline(
                'Entregada',
                'Por entregar',
                Icons.local_shipping,
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTimeline(
    String label,
    String valor,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionItems(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Artículos (${items.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length} item${items.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(item, index + 1);
            },
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay items en esta orden'),
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int numero) {
    final nombreProducto = item['producto_detail']?['nombre'] ?? 'Producto';
    final precioUnitario = item['precio_unitario'] ?? 0.00;
    final cantidad = item['cantidad'] ?? 1;
    final subtotal = item['subtotal'] ?? 0.00;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número del item
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
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
                        nombreProducto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${precioUnitario.toStringAsFixed(2)} x $cantidad',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionAdicional(Map<String, dynamic> orden) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Adicional',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildItemInfo(
              'ID de Orden',
              orden['id']?.toString() ?? 'N/A',
              Icons.tag,
            ),
            const SizedBox(height: 12),
            _buildItemInfo(
              'Método de Pago',
              orden['metodo_pago']?.toUpperCase() ?? 'No especificado',
              Icons.payment,
            ),
            if (orden['stripe_payment_intent_id'] != null) ...[
              const SizedBox(height: 12),
              _buildItemInfo(
                'Payment Intent ID',
                orden['stripe_payment_intent_id'].toString(),
                Icons.confirmation_number,
              ),
            ],
            const SizedBox(height: 12),
            _buildItemInfo(
              'Última Actualización',
              _formatearFecha(orden['updated_at']),
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(String label, String valor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion(BuildContext context, Map<String, dynamic> orden) {
    final estado = orden['estado'] ?? 'pendiente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón principal según estado
        if (estado == 'pendiente')
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Proceder al pago')));
            },
            icon: const Icon(Icons.payment),
            label: const Text('Proceder al Pago'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )
        else if (estado == 'pagada')
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Orden confirmada. Será enviada pronto.'),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Orden Confirmada'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )
        else if (estado == 'enviada')
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Orden en camino. Seguimiento disponible.'),
                ),
              );
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text('En Camino'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

        const SizedBox(height: 12),

        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de compartir disponible pronto'),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Función de descargar PDF disponible pronto',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Descargar'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Botón volver
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Volver'),
        ),
      ],
    );
  }
}
