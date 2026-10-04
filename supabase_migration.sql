-- =========================================================================
-- MIGRADOR SQL IDEMPOTENTE - VECINO ACTIVO (Seguridad y Funcionalidad Avanzada)
-- =========================================================================

-- 0. Ampliar tabla 'profiles' para incluir el rol ('ciudadano' o 'lider')
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    terminos_aceptados_version INTEGER,
    terminos_aceptados_at TIMESTAMP WITH TIME ZONE,
    role TEXT DEFAULT 'ciudadano' CHECK (role IN ('ciudadano', 'lider')),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Ver perfiles" ON public.profiles;
CREATE POLICY "Ver perfiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Actualizar propio perfil" ON public.profiles;
CREATE POLICY "Actualizar propio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Insertar propio perfil" ON public.profiles;
CREATE POLICY "Insertar propio perfil" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);


-- 1. Tabla 'reportes'
CREATE TABLE IF NOT EXISTS public.reportes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    categoria TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    fotos TEXT[] DEFAULT ARRAY[]::TEXT[],
    latitud DOUBLE PRECISION NOT NULL,
    longitud DOUBLE PRECISION NOT NULL,
    estado TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_seguimiento', 'canalizado', 'resuelto')),
    apoyos INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.reportes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede leer reportes" ON public.reportes;
CREATE POLICY "Cualquier usuario autenticado puede leer reportes"
    ON public.reportes FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Usuarios insertan sus propios reportes" ON public.reportes;
CREATE POLICY "Usuarios insertan sus propios reportes"
    ON public.reportes FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Solo el creador edita descripción o líderes actualizan estado. Prohibido modificar 'apoyos' directamente por clientes.
DROP POLICY IF EXISTS "Actualizar reportes (creador descripcion o lider estado)" ON public.reportes;
CREATE POLICY "Actualizar reportes (creador descripcion o lider estado)"
    ON public.reportes FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = user_id 
        OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'lider'
    )
    WITH CHECK (
        -- Si es el creador, solo puede cambiar descripcion (estado y apoyos no deben cambiar por su cuenta)
        (auth.uid() = user_id AND estado = (SELECT r.estado FROM public.reportes r WHERE r.id = id))
        OR
        -- Si es lider, puede cambiar estado
        ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'lider')
    );


-- 2. Tabla 'reporte_apoyos' para "Me afecta" (un voto por usuario por reporte)
CREATE TABLE IF NOT EXISTS public.reporte_apoyos (
    reporte_id UUID REFERENCES public.reportes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (reporte_id, user_id)
);

ALTER TABLE public.reporte_apoyos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Ver apoyos" ON public.reporte_apoyos;
CREATE POLICY "Ver apoyos" ON public.reporte_apoyos FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Insertar propio apoyo" ON public.reporte_apoyos;
CREATE POLICY "Insertar propio apoyo" ON public.reporte_apoyos FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Eliminar propio apoyo" ON public.reporte_apoyos;
CREATE POLICY "Eliminar propio apoyo" ON public.reporte_apoyos FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Función y trigger para actualizar automáticamente el contador 'apoyos' en 'reportes'
CREATE OR REPLACE FUNCTION public.fn_actualizar_apoyos()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.reportes SET apoyos = apoyos + 1 WHERE id = NEW.reporte_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.reportes SET apoyos = GREATEST(0, apoyos - 1) WHERE id = OLD.reporte_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_actualizar_apoyos ON public.reporte_apoyos;
CREATE TRIGGER trg_actualizar_apoyos
AFTER INSERT OR DELETE ON public.reporte_apoyos
FOR EACH ROW EXECUTE FUNCTION public.fn_actualizar_apoyos();


-- 3. Tabla 'comentarios'
CREATE TABLE IF NOT EXISTS public.comentarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reporte_id UUID REFERENCES public.reportes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    texto TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.comentarios ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Ver comentarios" ON public.comentarios;
CREATE POLICY "Ver comentarios" ON public.comentarios FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Insertar propio comentario" ON public.comentarios;
CREATE POLICY "Insertar propio comentario" ON public.comentarios FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);


-- 4. Tabla 'seguimientos' (historial de estatus por líderes)
CREATE TABLE IF NOT EXISTS public.seguimientos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reporte_id UUID REFERENCES public.reportes(id) ON DELETE CASCADE NOT NULL,
    lider_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    estado_nuevo TEXT NOT NULL,
    nota TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.seguimientos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Ver seguimientos" ON public.seguimientos;
CREATE POLICY "Ver seguimientos" ON public.seguimientos FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Solo líderes insertan seguimientos" ON public.seguimientos;
CREATE POLICY "Solo líderes insertan seguimientos" ON public.seguimientos
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = lider_id
        AND (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'lider'
    );

-- Trigger para registrar automáticamente en 'seguimientos' cuando un líder cambia el estado
CREATE OR REPLACE FUNCTION public.fn_registrar_seguimiento_cambio_estado()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.estado IS DISTINCT FROM NEW.estado) THEN
        INSERT INTO public.seguimientos (reporte_id, lider_id, estado_nuevo, nota)
        VALUES (
            NEW.id, 
            auth.uid(), 
            NEW.estado, 
            'Cambio de estado a ' || NEW.estado || ' por líder autorizado.'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_registrar_seguimiento ON public.reportes;
CREATE TRIGGER trg_registrar_seguimiento
AFTER UPDATE ON public.reportes
FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_seguimiento_cambio_estado();


-- 5. Bucket Storage 'reportes-fotos' (idempotente)
INSERT INTO storage.buckets (id, name, public)
VALUES ('reportes-fotos', 'reportes-fotos', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Acceso público de lectura a fotos de reportes" ON storage.objects;
CREATE POLICY "Acceso público de lectura a fotos de reportes"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'reportes-fotos');

DROP POLICY IF EXISTS "Usuarios autenticados suben fotos de reportes" ON storage.objects;
CREATE POLICY "Usuarios autenticados suben fotos de reportes"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'reportes-fotos');
