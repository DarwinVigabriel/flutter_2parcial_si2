// EJEMPLO DE INTEGRACIÓN EN CartScreen
// Este archivo muestra cómo conectar el CheckoutStripeScreen desde CartScreen

/* 
En CartScreen, en el botón de "Proceder al Pago", agregá:

  // En el onPressed del botón Proceder al Pago:
  onPressed: () async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    // Navegar a Checkout con Stripe
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutStripeScreen(
          carritoId: cartProvider.carritoId, // O el ID del carrito
        ),
      ),
    );
  },

---

FLUJO COMPLETO:
1. Usuario ve el carrito con productos
2. Usuario presiona "Proceder al Pago"
3. Navega a CheckoutStripeScreen
4. CheckoutStripeScreen crea la orden automáticamente
5. Usuario rellena datos de contacto
6. Usuario presiona "Pagar Ahora"
7. Se muestra Stripe Payment Sheet
8. Usuario completa el pago con su tarjeta
9. Pago se confirma en backend
10. Se muestra diálogo de éxito
11. Se limpia el carrito y vuelve a CartScreen

---

MÉTODOS DEL StripeProvider QUE SE PUEDEN USAR:

// Inicializar Stripe (se llama automáticamente en CheckoutScreen.initState)
await Provider.of<StripeProvider>(context, listen: false).inicializar();

// Procesar pago con Payment Sheet
final exitoso = await stripeProvider.procesarPagoConPaymentSheet(
  ordenId: '123-456',
  email: 'usuario@example.com',
  nombre: 'Juan Pérez',
  monto: 150.00,
);

// Reintentar pago (máximo 3 intentos)
if (stripeProvider.puedeReintentar) {
  await stripeProvider.reintentarPago(
    ordenId: '123-456',
    email: 'usuario@example.com',
    nombre: 'Juan Pérez',
    monto: 150.00,
  );
}

// Limpiar estado después de completar
stripeProvider.limpiarEstado();

---

ACCESO A PROPIEDADES:

// Estados booleanos
if (stripeProvider.procesando) { } // true mientras se procesa el pago
if (stripeProvider.pagoCorrecto) { } // true si pago fue exitoso

// Reintentos
int reintentos = stripeProvider.reintentos; // 0, 1, 2, 3
bool puede = stripeProvider.puedeReintentar; // true si reintentos < 3 y no pagoCorrecto

// Errores
String? error = stripeProvider.error; // Mensaje de error o null

---

INTEGRACIÓN EN CartScreen - EJEMPLO COMPLETO:

SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    onPressed: () async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      if (cartProvider.carrito.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El carrito está vacío')),
        );
        return;
      }

      // Mostrar diálogo de confirmación
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Proceder al Pago'),
          content: Text('Total: \$${cartProvider.total.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ) ?? false;

      if (confirmar && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutStripeScreen(
              carritoId: cartProvider.carritoId,
            ),
          ),
        );
      }
    },
    child: const Text('Proceder al Pago con Stripe'),
  ),
)

*/
