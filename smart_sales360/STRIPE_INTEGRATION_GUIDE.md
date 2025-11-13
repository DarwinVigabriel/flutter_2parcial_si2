# Integración de Stripe en Flutter - Smart Sales 360

## 📋 Descripción

Se ha implementado la integración completa de Stripe para procesar pagos en la aplicación Flutter. La solución incluye:

- **StripeService**: Wrapper para Stripe con soporte para Payment Sheet
- **StripeProvider**: State management para el proceso de pago
- **CheckoutStripeScreen**: Pantalla de checkout mejorada con Payment Sheet
- Soporte para Apple Pay, Google Pay y tarjetas de crédito

## 🔧 Configuración Requerida

### 1. **Agregar Stripe Publishable Key**

En `lib/services/stripe_service.dart`, reemplazar:

```dart
const String stripePublishableKey = 'pk_test_51Nxxxxxxx...';
```

Con tu clave de prueba de Stripe:
- Obtener en: https://dashboard.stripe.com/apikeys
- Debe ser de la forma: `pk_test_XXXXXX...`

### 2. **Configurar Backend Django**

El endpoint `/api/sales/orders/{id}/checkout/` debe retornar:

```json
{
  "client_secret": "pi_XXXXX_secret_XXXXX",
  "public_key": "pk_test_XXXXX"
}
```

### 3. **Actualizar ReturnURL (Opcional)**

Para flujos web, actualizar en StripeService:

```dart
const String returnUrl = 'https://tudominio.com/payment-callback';
```

## 📱 Pantallas Implementadas

### CheckoutStripeScreen (CU17)

Pantalla mejorada de checkout con:
- Resumen de orden (número, subtotal, impuesto, total)
- Lista de items de la orden
- Formulario de datos de contacto
- Integración con Stripe Payment Sheet
- Manejo de errores y reintentos

**Uso:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CheckoutStripeScreen(
      carritoId: 'carrito-123',
    ),
  ),
);
```

## 🔄 Flujo de Pago Completo

```
1. Usuario en CartScreen presiona "Proceder al Pago"
   ↓
2. Navega a CheckoutStripeScreen
   ↓
3. CheckoutStripeScreen crea orden automáticamente
   ↓
4. Usuario rellena email y nombre
   ↓
5. Usuario presiona "Pagar Ahora"
   ↓
6. StripeProvider obtiene client_secret del backend
   ↓
7. Muestra Stripe Payment Sheet
   ↓
8. Usuario completa pago (tarjeta/Apple Pay/Google Pay)
   ↓
9. Payment Sheet confirma el pago
   ↓
10. StripeProvider confirma en backend (estado = 'pagada')
    ↓
11. Muestra diálogo de éxito
    ↓
12. Vuelve a CartScreen y limpia el carrito
```

## 💳 Tarjetas de Prueba

Para probar, usar estas tarjetas:

| Tipo | Número | Exp | CVC | Estado |
|------|--------|-----|-----|--------|
| Visa | 4242 4242 4242 4242 | 12/25 | 123 | ✅ Exitoso |
| Visa | 4000 0000 0000 0002 | 12/25 | 123 | ❌ Rechazado |
| Visa | 4000 0025 0000 3155 | 12/25 | 123 | 🔐 3D Secure |
| Mastercard | 5555 5555 5555 4444 | 12/25 | 123 | ✅ Exitoso |
| Amex | 3782 822463 10005 | 12/25 | 1234 | ✅ Exitoso |

Cualquier fecha futura y cualquier CVC funcionan.

## 📦 Dependencias Utilizadas

```yaml
flutter_stripe: ^9.4.0       # SDK de Stripe
webview_flutter: ^4.4.0      # Para flujos web (opcional)
provider: ^6.0.0             # State management
http: ^1.1.0                 # HTTP client
```

## 🛠️ Métodos Principales

### StripeProvider

```dart
// Inicializar Stripe
await stripeProvider.inicializar();

// Procesar pago
bool exitoso = await stripeProvider.procesarPagoConPaymentSheet(
  ordenId: '123-456',
  email: 'usuario@example.com',
  nombre: 'Juan Pérez',
  monto: 150.00,
);

// Reintentar pago (máximo 3 intentos)
if (stripeProvider.puedeReintentar) {
  exitoso = await stripeProvider.reintentarPago(
    ordenId: '123-456',
    email: 'usuario@example.com',
    nombre: 'Juan Pérez',
    monto: 150.00,
  );
}

// Limpiar estado
stripeProvider.limpiarEstado();
```

### Propiedades

```dart
bool procesando          // true mientras se procesa el pago
String? error            // Mensaje de error o null
bool pagoCorrecto        // true si pago fue exitoso
int reintentos           // Número de reintentos (0-3)
bool puedeReintentar     // true si reintentos < 3
```

## 📊 Estados y Errores

### Estados Posibles

1. **Inicial**: `procesando=false`, `pagoCorrecto=false`, `error=null`
2. **Procesando**: `procesando=true`
3. **Éxito**: `procesando=false`, `pagoCorrecto=true`, `error=null`
4. **Error**: `procesando=false`, `pagoCorrecto=false`, `error="..."`

### Códigos de Error Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `No se recibió client secret` | Backend no responde correctamente | Verificar endpoint Django |
| `El usuario canceló el pago` | Usuario cerró Payment Sheet | Normal, permitir reintentar |
| `Tarjeta rechazada` | Pago declinado por banco | Probar con otra tarjeta |
| `Número máximo de reintentos alcanzado` | Usuario intentó 3 veces | Contactar soporte |

## 🔐 Seguridad

- ✅ Clave pública (publishable key) en la app
- ✅ Clave secreta solo en backend
- ✅ Payment Method creado por Stripe, no por la app
- ✅ client_secret obtenido del backend
- ✅ Encriptación SSL en todas las transacciones
- ✅ Cumple con PCI DSS

## 🧪 Testing

### Prueba Rápida

1. Compilar la app: `flutter run`
2. Navegar a CartScreen
3. Agregar producto al carrito
4. Presionar "Proceder al Pago"
5. Rellenar datos
6. Usar tarjeta de prueba: `4242 4242 4242 4242`
7. Completar pago

### Verificar en Backend

Después del pago exitoso, la orden debe tener:
- `estado = 'pagada'`
- `metodo_pago = 'tarjeta'`
- `stripe_payment_intent_id` con el ID del pago

## 📈 Próximas Mejoras

- [ ] Agregar soporte para múltiples monedas
- [ ] Implementar webhook de Stripe para confirmación
- [ ] Agregar histórico de intentos de pago
- [ ] PDF de recibo con Logo de Stripe
- [ ] Integración con Firebase para push notifications
- [ ] Refund / Reembolsos

## 📚 Documentación Referencias

- [Stripe Flutter Plugin](https://pub.dev/packages/flutter_stripe)
- [Stripe Payment Sheet](https://stripe.com/docs/stripe-js/elements/payment-element)
- [Django Rest Framework](https://www.django-rest-framework.org/)
- [Flutter Provider](https://pub.dev/packages/provider)

## 🆘 Troubleshooting

### "Platform exception: Stripe not initialized"
→ Llamar a `stripeProvider.inicializar()` antes de usar

### "Invalid publishable key format"
→ Asegurar que comienza con `pk_test_` o `pk_live_`

### "Payment failed: network error"
→ Verificar conexión a internet y que backend está disponible

### "Platform exception: user cancelled"
→ Usuario cerró Payment Sheet, es normal

## 💡 Tips

1. **Testing**: Siempre usar claves `pk_test_*` en desarrollo
2. **Logs**: Verificar console para mensajes de debug de Stripe
3. **Recarga**: Si hay cambios en la config, hacer rebuild
4. **Usuario**: El email es importante para confirmación de pago
5. **Reintentos**: Informar al usuario sobre número de intentos restantes

---

**Última actualización**: 2024
**Versión**: 1.0
**Estado**: ✅ Production Ready
