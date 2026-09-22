# CausApp 🌿

CausApp es una aplicación móvil y web desarrollada en **Flutter** y **Supabase** para conectar a ciudadanos con iniciativas, jornadas comunitarias y voluntariados ambientales y sociales.

---

## 🗺️ OpenStreetMap (100% Gratis sin API Keys)

CausApp utiliza **OpenStreetMap** a través de los paquetes `flutter_map` y `latlong2`, lo que permite mostrar mapas interactivos de alta calidad, marcadores de jornadas y geolocalización sin necesidad de configurar claves de API de pago ni restricciones de Google Maps.

---

## ✨ Características Principales

- **Autenticación y Perfiles:** Registro, inicio de sesión seguro con Supabase Auth y gestión de términos y condiciones.
- **Jornadas Comunitarias y Ambientales:** Descubre, crea, edita y participa en jornadas de voluntariado.
- **Mapa Interactivo:** Visualización geolocalizada de jornadas utilizando OpenStreetMap.
- **Modo Offline-First:** Almacenamiento local mediante Drift (SQLite) con sincronización inteligente y caché.
- **Gestión de Recursos y Préstamos:** Préstamo e intercambio de herramientas y materiales necesarios para las jornadas.
- **Módulo de Donaciones:** Apoyo monetario y en especie a las iniciativas comunitarias.
- **Notificaciones Locales:** Recordatorios y alertas para las jornadas inscritas u organizadas.

---

## 🛠️ Tecnologías

- **Framework:** Flutter (Dart)
- **Backend & Auth:** Supabase (PostgreSQL + RLS)
- **Estado:** Flutter Riverpod
- **Base de Datos Local:** Drift (SQLite)
- **Mapas:** flutter_map & latlong2 (OpenStreetMap)
- **Geolocalización:** geolocator
- **Notificaciones:** flutter_local_notifications

---

## 🏗️ Arquitectura

CausApp sigue una estructura modular orientada a separación de responsabilidades:
- `lib/models/`: Modelos de datos serializables.
- `lib/repositories/`: Capa de persistencia y comunicación con Supabase y Drift (Cache-then-Network).
- `lib/controllers/`: Proveedores Riverpod y lógica de estado.
- `lib/screens/`: Pantallas de la interfaz de usuario (Material 3).
- `lib/local_db/`: Base de datos local Drift.
- `lib/services/`: Servicios auxiliares (notificaciones).

---

## 🚀 Instalación y Ejecución

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/PetterAven/CausApp.git
   cd CausApp
   ```

2. Instalar dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

---

## 🔐 Configuración Manual y Secretos

Consulta la guía detallada de configuración de Supabase y permisos móviles en [SETUP_MANUAL.md](SETUP_MANUAL.md).

---

## 🧪 Testing y Calidad

Para ejecutar las pruebas unitarias y de widgets:
```bash
flutter test
```

Para verificar el análisis estático de código:
```bash
flutter analyze
```

---

## 🚀 Roadmap

- Integración de pasarelas de pago reales (Stripe/PayPal) para donaciones monetarias.
- Chat en tiempo real entre organizadores y voluntarios mediante Supabase Realtime.
- Ampliación de la cobertura de pruebas unitarias y de integración.

---

## 👤 Autor

Brayan Pedro Avendaño
