import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orden_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late OrdenProvider _ordenProvider;

  @override
  void initState() {
    super.initState();
    _ordenProvider = Provider.of<OrdenProvider>(context, listen: false);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _ordenProvider.cargarResumenDashboard(),
      _ordenProvider.cargarAlertas(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
                    onPressed: _cargarDatos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final resumen = ordenProvider.resumenDashboard;
          final alertas = ordenProvider.alertas;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen rápido
                if (resumen != null) ...[
                  Text(
                    'Bienvenido, ${resumen['usuario_nombre'] ?? 'Usuario'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),

                  // Tarjetas de resumen
                  _buildResumenCard(
                    titulo: 'Total Vendido',
                    valor: '\$${resumen['total_vendido'] ?? 0.00}',
                    icono: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  _buildResumenCard(
                    titulo: 'Total de Órdenes',
                    valor: '${resumen['total_ordenes'] ?? 0}',
                    icono: Icons.receipt,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  _buildResumenCard(
                    titulo: 'Promedio por Orden',
                    valor: '\$${resumen['promedio_venta'] ?? 0.00}',
                    icono: Icons.trending_up,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                ],

                // Alertas
                if (alertas.isNotEmpty) ...[
                  Text(
                    'Alertas Importantes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];
                      return _buildAlertaCard(alerta);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Botones de acción
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a historial de órdenes
                      Navigator.pushNamed(context, '/historial-ordenes');
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Ver Historial de Órdenes'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a notificaciones
                      Navigator.pushNamed(context, '/notificaciones');
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Ver Notificaciones'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumenCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaCard(dynamic alerta) {
    final tipo = alerta['tipo'] ?? 'unknown';
    final titulo = alerta['titulo'] ?? 'Alerta';
    final mensaje = alerta['mensaje'] ?? '';
    final nivel = alerta['nivel'] ?? 'info';

    final color = _getColorNivel(nivel);
    final icono = _getIconoNivel(nivel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                  const SizedBox(height: 4),
                  Text(
                    mensaje,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getIconoNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }
}
