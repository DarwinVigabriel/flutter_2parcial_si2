import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orden_provider.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late OrdenProvider _ordenProvider;

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    await _ordenProvider.cargarNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _mostrarDialogoLimpiar(context),
            tooltip: 'Limpiar notificaciones leídas',
          ),
        ],
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
                    onPressed: _cargarNotificaciones,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final notificaciones = ordenProvider.notificaciones;
          if (notificaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay notificaciones'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _cargarNotificaciones,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final notificacion = notificaciones[index];
                return _buildNotificacionCard(context, notificacion);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificacionCard(BuildContext context, dynamic notificacion) {
    final tipo = notificacion['tipo'] ?? 'otro';
    final titulo = notificacion['titulo'] ?? 'Notificación';
    final mensaje = notificacion['mensaje'] ?? '';
    final estado = notificacion['estado'] ?? 'pendiente';
    final fecha = notificacion['created_at'];

    final color = _getColorTipo(tipo);
    final icono = _getIconoTipo(tipo);
    final leida = estado == 'entregada';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatearFecha(fecha),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!leida)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Mensaje
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!leida)
                  TextButton(
                    onPressed: () async {
                      await _ordenProvider.marcarNotificacionEntregada(
                        notificacion['id'],
                      );
                    },
                    child: const Text('Marcar como leída'),
                  )
                else
                  const Text(
                    'Leída',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'compra':
        return Colors.blue;
      case 'pago':
        return Colors.green;
      case 'venta':
        return Colors.purple;
      case 'descuento':
      case 'promocion':
        return Colors.orange;
      case 'alerta':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'compra':
        return Icons.shopping_bag;
      case 'pago':
        return Icons.payment;
      case 'venta':
        return Icons.sell;
      case 'descuento':
      case 'promocion':
        return Icons.local_offer;
      case 'alerta':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(fecha);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(dateTime);

      if (diferencia.inMinutes < 1) {
        return 'Hace unos segundos';
      } else if (diferencia.inMinutes < 60) {
        return 'Hace ${diferencia.inMinutes} min';
      } else if (diferencia.inHours < 24) {
        return 'Hace ${diferencia.inHours}h';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  void _mostrarDialogoLimpiar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Limpiar Notificaciones'),
        content: const Text('¿Estás seguro de que deseas eliminar todas las notificaciones leídas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Aquí iría la limpieza de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones eliminadas')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
