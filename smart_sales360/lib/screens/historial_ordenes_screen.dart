import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orden_provider.dart';

class HistorialOrdenesScreen extends StatefulWidget {
  const HistorialOrdenesScreen({Key? key}) : super(key: key);

  @override
  State<HistorialOrdenesScreen> createState() => _HistorialOrdenesScreenState();
}

class _HistorialOrdenesScreenState extends State<HistorialOrdenesScreen> {
  late OrdenProvider _ordenProvider;
  String _estadoSeleccionado = 'todos';

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    String? estado = _estadoSeleccionado == 'todos' ? null : _estadoSeleccionado;
    await _ordenProvider.cargarOrdenes(estado: estado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Órdenes'),
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
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${ordenProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarOrdenes,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final ordenes = ordenProvider.ordenes;
          if (ordenes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay órdenes'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Filtro por estado
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFiltroButton('todos', 'Todas'),
                    const SizedBox(width: 8),
                    _buildFiltroButton('pendiente', 'Pendientes'),
                    const SizedBox(width: 8),
                    _buildFiltroButton('pagada', 'Pagadas'),
                    const SizedBox(width: 8),
                    _buildFiltroButton('entregada', 'Entregadas'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Lista de órdenes
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ordenes.length,
                itemBuilder: (context, index) {
                  final orden = ordenes[index];
                  return _buildOrdenCard(context, orden);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltroButton(String valor, String etiqueta) {
    final isSeleccionado = _estadoSeleccionado == valor;
    return FilterChip(
      label: Text(etiqueta),
      selected: isSeleccionado,
      onSelected: (bool selected) {
        setState(() {
          _estadoSeleccionado = valor;
        });
        _cargarOrdenes();
      },
    );
  }

  Widget _buildOrdenCard(BuildContext context, dynamic orden) {
    final estado = orden['estado'] ?? 'desconocido';
    final color = _getColorEstado(estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con número de orden y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orden #${orden['numero_orden'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información de la orden
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${orden['total'] ?? 0.00}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${orden['items_count'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearFecha(orden['created_at']),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botón de ver detalles
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Aquí iría la navegación a pantalla de detalles
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Detalles de ${orden['numero_orden']}')),
                  );
                },
                child: const Text('Ver Detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
      case 'entregada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      case 'confirmada':
      case 'enviada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
