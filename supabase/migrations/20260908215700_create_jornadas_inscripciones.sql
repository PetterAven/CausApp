create table jornadas (
  id uuid primary key default gen_random_uuid(),
  organizador_id uuid references auth.users(id) not null,
  titulo text not null,
  categoria text not null,
  categoria_personalizada text,
  descripcion text,
  fecha date not null,
  hora time not null,
  latitud float8 not null,
  longitud float8 not null,
  direccion_referencia text,
  cupo_voluntarios int,
  estado text default 'activa',
  created_at timestamptz default now()
);

create table inscripciones (
  id uuid primary key default gen_random_uuid(),
  jornada_id uuid references jornadas(id) not null,
  voluntario_id uuid references auth.users(id) not null,
  created_at timestamptz default now(),
  unique (jornada_id, voluntario_id)
);

alter table jornadas enable row level security;
alter table inscripciones enable row level security;

create policy "Ver jornadas" on jornadas for select using (true);
create policy "Crear jornadas" on jornadas for insert with check (auth.uid() = organizador_id);
create policy "Editar propias jornadas" on jornadas for update using (auth.uid() = organizador_id);

create policy "Ver inscripciones" on inscripciones for select using (true);
create policy "Inscribirse" on inscripciones for insert with check (auth.uid() = voluntario_id);
create policy "Cancelar propia inscripción" on inscripciones for delete using (auth.uid() = voluntario_id);
