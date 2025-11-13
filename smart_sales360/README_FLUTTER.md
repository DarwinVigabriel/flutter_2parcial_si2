# 📱 Smart Sales 360 - Flutter App (CU7-CU10)

Aplicación móvil Flutter para **Smart Sales 360** con implementación de casos de uso CU7 a CU10.

## ✨ Características Implementadas

### 🔐 CU7: Iniciar Sesión en App Móvil
- Login con email y contraseña
- Validación de credenciales
- Almacenamiento seguro de tokens (JWT)
- Manejo de errores y estados de carga

### 🛍️ CU8: Ver Lista de Productos en Móvil
- Listado completo de productos en grid
- Búsqueda y filtrado de productos
- Información de precio y stock
- Detalles del producto al seleccionar

### 🛒 CU9: Gestionar Carrito de Compra en Móvil
- Crear carrito automáticamente
- Agregar productos con cantidad variable
- Actualizar cantidades de items
- Eliminar productos del carrito
- Vaciar carrito completo
- Mostrar subtotal y total
- Resumen visual del carrito

### 📷 CU10: Escanear Código de Barras de Productos
- Escaneo de códigos de barras
- Búsqueda manual de productos por código
- Agregar producto escaneado al carrito
- Confirmación visual del producto encontrado

## 🎨 Diseño y Colores

### Paleta de Colores (Granate + Arena)
- **Primario:** #8B1E2D (Granate)
- **Primario Hover:** #721626
- **Primario Suave:** #F8E7E9
- **Secundario:** #0EA5E9 (Celeste)
- **Fondo:** #FAFAF7
- **Texto Principal:** #191919
- **Éxito:** #16A34A
- **Error:** #B91C1C

Ver `lib/config/app_colors.dart` para toda la paleta.

## 📂 Estructura del Proyecto

```
lib/
├── config/
│   ├── app_colors.dart       # Definición de colores
│   ├── app_theme.dart        # Temas de la app
│   └── api_config.dart       # Configuración de API
├── models/
│   ├── user.dart             # Modelo de usuario
│   ├── product.dart          # Modelo de producto
│   ├── cart.dart             # Modelo de carrito
│   ├── api_response.dart     # Modelo de respuesta API
│   └── index.dart            # Exports
├── services/
│   ├── storage_service.dart  # Almacenamiento local (SharedPrefs)
│   └── api_service.dart      # Llamadas a API
├── providers/
│   ├── auth_provider.dart    # Proveedor de autenticación
│   ├── product_provider.dart # Proveedor de productos
│   └── cart_provider.dart    # Proveedor de carrito
├── screens/
│   ├── login_screen.dart     # Pantalla de login (CU7)
│   ├── products_screen.dart  # Pantalla de productos (CU8)
│   ├── cart_screen.dart      # Pantalla de carrito (CU9)
│   ├── qr_scanner_screen.dart # Pantalla QR scanner (CU10)
│   └── home_screen.dart      # Pantalla principal
├── widgets/
│   ├── buttons.dart          # Botones personalizados
│   └── text_field.dart       # Campos de texto
├── utils/
└── main.dart                 # Punto de entrada
```

## 🚀 Instalación y Configuración

### 1. Clonar y Dependencias
```bash
cd flutter/smart_sales360
flutter pub get
```

### 2. Configurar Base URL
Edita `lib/config/api_config.dart`:
```dart
// Desarrollo local
static const String baseUrl = 'http://192.168.1.100:8000';

// Producción
// static const String baseUrl = 'https://api.smartsales360.com';
```

### 3. Ejecutar la App
```bash
# Desarrollo
flutter run

# Modo release
flutter run --release
```

## 📝 Flujo de Uso

1. **Login (CU7)**
   - Ingresar email y contraseña
   - Token se guarda automáticamente
   - Redirige a pantalla principal

2. **Ver Productos (CU8)**
   - Listado de todos los productos
   - Búsqueda por nombre/SKU
   - Ver precios y stock disponible

3. **Escanear QR (CU10)**
   - Presionar botón de escaneo
   - Capturar código de barras
   - Seleccionar cantidad
   - Agregar al carrito

4. **Gestionar Carrito (CU9)**
   - Ver items agregados
   - Modificar cantidades
   - Eliminar productos
   - Ver total y proceder al pago

## 🔌 API Endpoints Utilizados

```
POST   /api/auth/login/                          - CU7
GET    /api/products/products/                   - CU8
GET    /api/products/products/lookup_by_barcode/ - CU10
POST   /api/sales/carts/                         - CU9
POST   /api/sales/carts/{id}/add_item/           - CU9
POST   /api/sales/carts/{id}/update_item/        - CU9
POST   /api/sales/carts/{id}/remove_item/        - CU9
POST   /api/sales/carts/{id}/clear/              - CU9
```

## 📦 Dependencias Principales

```yaml
http: ^1.1.0                    # Cliente HTTP
shared_preferences: ^2.2.0      # Almacenamiento local
mobile_scanner: ^3.5.0          # Scanner QR
provider: ^6.0.0                # State management
json_annotation: ^4.8.0         # JSON serialization
sqflite: ^2.3.0                 # Base de datos local
```

## 🧪 Testing Manual

### Test de Login
1. Email: `test@example.com`
2. Password: `password123`
3. Esperar confirmación

### Test de Productos
1. Ver listado de productos
2. Buscar "laptop" o similar
3. Ver detalles del producto

### Test de QR Scanner
1. Presionar botón QR
2. Ingresar código manualmente o escanear
3. Verificar que agregue al carrito

### Test de Carrito
1. Agregar varios productos
2. Actualizar cantidades
3. Eliminar items
4. Vaciar carrito

## 📱 Requisitos Mínimos

- Flutter SDK: 3.8.1+
- Dart SDK: 3.8.1+
- Android API 21+ o iOS 11+
- Conexión a Internet

## 🔐 Autenticación y Seguridad

- Tokens JWT almacenados en SharedPreferences
- Tokens incluidos en headers de cada petición
- Logout limpia todos los datos locales
- Validación de formularios en cliente

## 🎯 Próximas Características

- [x] CU7: Login
- [x] CU8: Productos
- [x] CU9: Carrito
- [x] CU10: QR Scanner
- [ ] CU11: Checkout y pago
- [ ] CU12: Confirmación de compra
- [ ] CU18: Historial de compras
- [ ] CU20: Notificaciones push
- [ ] Modo oscuro completo
- [ ] Persistencia offline

## 🐛 Solución de Problemas

### Problema: Error de conexión a API
**Solución:** Verificar `ApiConfig.baseUrl` y que el backend esté corriendo.

### Problema: Tokens expirados
**Solución:** Implementar refresh de tokens en `ApiService.

### Problema: Permisos de cámara
**Solución:** Agregar permisos en `AndroidManifest.xml` e `Info.plist`.

## 📞 Contacto y Soporte

- Proyecto: Smart Sales 360
- Versión Flutter: 1.0.0
- Última actualización: 12 de Noviembre, 2025

---

**Nota:** Esta app está en desarrollo y lista para testing. Los colores y diseño siguen la paleta institucional especificada.
