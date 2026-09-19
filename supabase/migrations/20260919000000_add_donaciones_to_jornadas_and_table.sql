-- Agregar columnas de donaciones a la tabla jornadas
alter table jornadas add column if not exists acepta_donaciones_dinero boolean default false;
alter table jornadas add column if not exists acepta_donaciones_articulos boolean default false;
alter table jornadas add column if not exists meta_donacion_dinero numeric;
alter table jornadas add column if not exists articulos_solicitados jsonb default '[]'::jsonb;

-- Crear tabla donaciones
create table if not exists donaciones (
  id uuid primary key default gen_random_uuid(),
  jornada_id uuid references jornadas(id) on delete cascade not null,
  donante_id uuid references auth.users(id) not null,
  tipo text check (tipo in ('dinero','articulo')) not null,
  monto numeric,
  articulo_descripcion text,
  cantidad int,
  estado text default 'pendiente' check (estado in ('pendiente','confirmada','cancelada')),
  created_at timestamptz default now()
);

alter table donaciones enable row level security;

create policy "Ver donaciones" on donaciones for select using (true);
create policy "Crear donacion" on donaciones for insert with check (auth.uid() = donante_id);
create policy "Ver propias donaciones o de jornada propia" on donaciones for select using (auth.uid() = donante_id or auth.uid() in (select organizador_id from jornadas where id = jornada_id));
