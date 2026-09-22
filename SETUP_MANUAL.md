# Guía de Configuración Manual (SETUP_MANUAL.md)

Este documento detalla los pasos manuales necesarios para configurar, desplegar y conectar los servicios externos de **CausApp** (Supabase, permisos móviles, etc.).

---

## 1. Configuración de Supabase

CausApp utiliza Supabase como Backend-as-a-Service para autenticación, base de datos PostgreSQL, almacenamiento y políticas de seguridad (RLS).

### Pasos para configurar el proyecto en Supabase:
1. Inicia sesión en [Supabase Dashboard](https://supabase.com).
2. Crea un nuevo proyecto (ej. `causapp-prod`).
3. Una vez creado el proyecto, ve a **Project Settings > API**:
   - Copia la **Project URL** (ej. `https://xxx.supabase.co`).
   - Copia la clave **anon / public** (Publishable Key).
   - *Nota de Seguridad:* NUNCA expongas ni utilices la clave `service_role` en la aplicación cliente de Flutter.

---

## 2. Ejecución de Migraciones SQL en Supabase

Las tablas y políticas de seguridad (RLS) se encuentran versionadas en el directorio `supabase/migrations/`.

### Pasos para ejecutar las migraciones:
1. En el panel de tu proyecto en Supabase, haz clic en **SQL Editor** en el menú lateral izquierdo.
2. Haz clic en **New query**.
3. Abre los archivos ubicados en el repositorio local bajo `supabase/migrations/` en orden cronológico:
   - `20260908215700_create_jornadas_inscripciones.sql`
   - `20260916000000_create_recursos_prestamo.sql`
   - `20260916120000_add_herramientas_necesarias_y_fecha_publicacion.sql`
   - `20260917000000_create_encuestas_satisfaccion_estado.sql`
   - `20260918000000_create_profiles_terms.sql`
   - `20260919000000_add_donaciones_to_jornadas_and_table.sql`
   - `20260920000000_add_articulo_columns_to_donaciones.sql`
4. Copia el contenido de cada archivo SQL, pégalo en el editor de Supabase y presiona **Run**.

---

## 3. Configuración de Autenticación en Supabase
1. En el panel de Supabase, ve a **Authentication > Providers**.
2. Habilita **Email** (y opcionalmente proveedores OAuth si se desean configurar).
3. Configura las URLs de redireccionamiento si usas autenticación web o móvil profunda (Deep Linking).

---

## 4. Configuración de Permisos en Android e iOS (Mapas y Geolocalización)

CausApp utiliza `geolocator` y `flutter_map` (OpenStreetMap).

### Android (`android/app/src/main/AndroidManifest.xml`)
Asegúrate de que estén presentes los permisos de ubicación:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`)
Asegúrate de incluir las descripciones de uso de ubicación:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>CausApp necesita acceso a tu ubicación para mostrar jornadas comunitarias y ambientales cercanas en el mapa.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>CausApp necesita acceso a tu ubicación para mostrar jornadas comunitarias y ambientales cercanas en el mapa.</string>
```

---

## 5. Ejecución Local del Proyecto
Una vez configurado Supabase:
```bash
flutter pub get
flutter run
```
