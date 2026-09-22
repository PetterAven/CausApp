# Auditoría Completa de CausApp (AUDIT.md)

Este documento detalla la auditoría técnica completa del proyecto CausApp según los estándares de ingeniería senior en Flutter, Supabase, seguridad, offline-first y arquitectura.

---

## 1. Estructura y Arquitectura del Proyecto
- **Problema encontrado:** Organización plana/híbrida en `lib/` (`models`, `repositories`, `controllers`, `screens`, `widgets`, `services`, `local_db`). Aunque funcional, los controladores y servicios manejan lógica mixta sin separación clara de Domain/Data/Presentation en características (feature-first).
- **Archivo afectado:** `lib/` (estructura global de carpetas).
- **Gravedad:** BAJA
- **Explicación:** El código es limpio y modular dentro de sus carpetas actuales, pero beneficiaría de una organización más estructurada para escalabilidad profesional.
- **Solución recomendada:** Mantener la estructura actual para evitar romper importaciones existentes, pero documentar y organizar futuras extensiones con un enfoque feature-first.
- **Automatizable:** No.
- **Requiere intervención manual:** No.

## 2. Seguridad en Supabase y Claves
- **Problema encontrado:** La URL y la `publishableKey` de Supabase están hardcodeadas en `lib/main.dart`. Aunque es una clave pública (`anon` / `publishableKey`), es mejor práctica gestionarla mediante variables de entorno o constantes configurables si se compila para producción.
- **Archivo afectado:** `lib/main.dart`
- **Gravedad:** MEDIA
- **Explicación:** Las publishable keys de Supabase son seguras de exponer en el cliente por diseño (gracias a RLS), pero hardcodearlas dificulta cambiar de entorno (dev/staging/prod).
- **Solución recomendada:** Documentar el uso de `--dart-define` o mantenerlas de forma segura, verificando que NUNCA se incluya una `service_role` key en el código cliente.
- **Automatizable:** Parcial.
- **Requiere intervención manual:** Sí, al configurar credenciales de producción.

## 3. Row Level Security (RLS) en Supabase
- **Problema encontrado:** Las políticas RLS están correctamente habilitadas en las migraciones SQL para `jornadas`, `inscripciones`, `profiles`, `recursos_prestamo`, `mensajes_recurso` y `donaciones`.
- **Archivo afectado:** `supabase/migrations/`
- **Gravedad:** BAJA (¡Buen diseño!)
- **Explicación:** Las políticas aseguran que los usuarios autenticados operen según su rol (`auth.uid() = organizador_id`, `auth.uid() = voluntario_id`, etc.).
- **Solución recomendada:** Verificar que todas las tablas nuevas en futuras migraciones mantengan `alter table ... enable row level security;`.
- **Automatizable:** Sí (vía migraciones SQL).
- **Requiere intervención manual:** Ejecutar las migraciones en el dashboard de Supabase si no se usa Supabase CLI linked.

## 4. Manejo Offline (Drift / SQLite)
- **Problema encontrado:** La aplicación cuenta con una implementación parcial robusta con Drift (`AppDatabase`), pero la sincronización automática bidireccional y la gestión de cola de pendientes (`pendingSync`) requieren atención en algunos repositorios.
- **Archivo afectado:** `lib/local_db/app_database.dart`, repositorios.
- **Gravedad:** MEDIA
- **Explicación:** El modo offline está preparado estructuralmente en Drift, pero algunos flujos dependen directamente de Supabase sin fallback automático transparente.
- **Solución recomendada:** Reforzar el manejo offline para que las operaciones de lectura consulten SQLite en caso de fallo de red y registren eventos en cola.
- **Automatizable:** Sí.
- **Requiere intervención manual:** No.

## 5. Manejo de Errores y UI States
- **Problema encontrado:** Algunos bloques `catch` usan `debugPrint` o muestran errores crudos en la interfaz sin mensajes amigables al usuario.
- **Archivo afectado:** Diversos controladores y pantallas (`lib/controllers/`, `lib/screens/`).
- **Gravedad:** MEDIA
- **Explicación:** Los usuarios finales necesitan mensajes claros ("No se pudo conectar", "Inténtalo de nuevo") en lugar de excepciones técnicas.
- **Solución recomendada:** Estandarizar la captura de excepciones y mostrar `SnackBar` o diálogos con mensajes localizados y amigables.
- **Automatizable:** Sí.
- **Requiere intervención manual:** No.

## 6. Mapas y Geolocalización (OpenStreetMap)
- **Problema encontrado:** Uso correcto de `flutter_map` y `geolocator` sin dependencias de API de Google Maps de pago. Sin embargo, se debe verificar el manejo de permisos denegados o GPS desactivado en Android/iOS.
- **Archivo afectado:** `lib/screens/mapa_jornadas_screen.dart`, `lib/screens/crear_jornada_screen.dart`
- **Gravedad:** BAJA
- **Explicación:** El mapa funciona perfectamente con OpenStreetMap tiles gratuitos.
- **Solución recomendada:** Asegurar manejo elegante cuando los permisos de ubicación sean denegados permanentemente.
- **Automatizable:** Sí.
- **Requiere intervención manual:** Configurar permisos en `AndroidManifest.xml` e `Info.plist` si faltaran.

## 7. Testing y Calidad de Código
- **Problema encontrado:** Solo existe el test por defecto de widgets (`test/widget_test.dart`). Faltan unit tests para repositorios y controladores críticos.
- **Archivo afectado:** `test/`
- **Gravedad:** ALTA (para portafolio profesional)
- **Explicación:** Un portafolio senior requiere cobertura de pruebas en lógica de negocio y repositorios.
- **Solución recomendada:** Añadir pruebas unitarias y de widgets esenciales (ej. autenticación, validaciones, repositorios con mocks).
- **Automatizable:** Sí.
- **Requiere intervención manual:** No.

## 8. CI/CD y Automatización
- **Problema encontrado:** Ausencia de un workflow de GitHub Actions para análisis estático y pruebas automáticas.
- **Archivo afectado:** Nuevo archivo `.github/workflows/flutter.yml` requerido.
- **Gravedad:** MEDIA
- **Explicación:** Automatizar `flutter analyze` y `flutter test` en GitHub Actions garantiza la calidad continua del repositorio.
- **Solución recomendada:** Crear el workflow de GitHub Actions.
- **Automatizable:** Sí.
- **Requiere intervención manual:** Habilitar Actions en el repositorio de GitHub.
