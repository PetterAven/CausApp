# CausApp 🌿

CausApp es una aplicación móvil y web desarrollada en Flutter y Supabase para conectar a ciudadanos con iniciativas, jornadas comunitarias y voluntariados ambientales y sociales.

---

## 🗺️ Configuración de Google Maps (Solución al problema del Mapa)

Para que los mapas funcionen correctamente en dispositivos físicos y emuladores, es necesario configurar una **API Key válida de Google Maps**:

### 1. Android (`android/app/src/main/AndroidManifest.xml`)
Reemplaza `TU_API_KEY_DE_GOOGLE_MAPS` con tu clave de API de Google Maps dentro del bloque `<application>`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_REAL_AQUI" />
```

### 2. iOS (`ios/Runner/AppDelegate.swift`)
Importa GoogleMaps y provee la API Key en el método de inicio:
```swift
import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_REAL_AQUI")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  ...
}
```

---

## ✨ Mejoras de Interfaz (UI/UX)
- **Tema Material 3 moderno**: Paleta de colores optimizada con tonos verde esmeralda (`#2E7D32`), tarjetas con sombras suaves y esquinas redondeadas.
- **Pantallas rediseñadas**:
  - `LoginScreen`: Tarjetas limpias, avatares e indicadores de carga fluidos.
  - `MapaJornadasScreen`: Filtros superiores deslizables (`ChoiceChip`) y tarjetas flotantes de detalle.
  - `CrearJornadaScreen`: Formulario estructurado con validaciones y vista previa del mapa interactivo.
  - `MisJornadasScreen`: Pestañas organizadas entre jornadas en las que estás inscrito y las que organizas.
  - `PerfilScreen`: Perfil de usuario moderno con acceso directo a creación y cierre de sesión.

---

## 🚀 Ejecución

```bash
flutter pub get
flutter run
```
