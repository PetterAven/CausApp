# CausApp 🌿

CausApp es una aplicación móvil y web desarrollada en Flutter y Supabase para conectar a ciudadanos con iniciativas, jornadas comunitarias y voluntariados ambientales y sociales.

---

## 🗺️ OpenStreetMap (100% Gratis sin API Keys)

CausApp utiliza **OpenStreetMap** a través de los paquetes `flutter_map` y `latlong2`, lo que permite mostrar mapas interactivos de alta calidad, marcadores de jornadas y geolocalización sin necesidad de configurar claves de API de pago ni restricciones de Google Maps.

---

## ✨ Mejoras de Interfaz (UI/UX) y Características
- **Tema Material 3 esmeralda (#2E7D32)**: Paleta de colores optimizada, tarjetas con sombras suaves y esquinas redondeadas.
- **Fondo Animado Sutil (`AnimatedBackground`)**: Animación performante y elegante basada en `CustomPainter` con tonos verdes suaves.
- **Estructura de Donaciones (UI + Supabase)**: Módulo de donaciones sin pasarela de pago real, preparado para integración futura con Stripe / PayPal.
- **Pantallas rediseñadas**:
  - `LoginScreen`: Tarjetas limpias, avatares e indicadores de carga fluidos.
  - `MapaJornadasScreen`: Filtros superiores deslizables (`ChoiceChip`) y tarjetas flotantes de detalle.
  - `CrearJornadaScreen`: Formulario estructurado con validaciones y vista previa del mapa interactivo.
  - `MisJornadasScreen`: Pestañas organizadas entre jornadas en las que estás inscrito y las que organizas.
  - `PerfilScreen`: Perfil de usuario moderno con acceso directo a creación, donación y cierre de sesión.

---

## 🚀 Ejecución

```bash
flutter pub get
flutter run
```
