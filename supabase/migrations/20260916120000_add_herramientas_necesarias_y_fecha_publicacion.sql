-- Agregar columna herramientas_necesarias a la tabla jornadas
ALTER TABLE jornadas ADD COLUMN IF NOT EXISTS herramientas_necesarias TEXT[];

-- Agregar columna fecha_publicacion a la tabla recursos_prestamo si no existe
ALTER TABLE recursos_prestamo ADD COLUMN IF NOT EXISTS fecha_publicacion TIMESTAMPTZ DEFAULT NOW();
