create table recursos_prestamo (
  id uuid primary key default gen_random_uuid(),
  jornada_id uuid references jornadas(id) on delete set null,
  usuario_id uuid references auth.users(id) not null,
  nombre_articulo text not null,
  cantidad int not null default 1,
  descripcion text,
  estado text not null default 'disponible', -- 'disponible', 'prestado', 'no_disponible'
  fecha_publicacion timestamptz default now()
);

create table mensajes_recurso (
  id uuid primary key default gen_random_uuid(),
  recurso_id uuid references recursos_prestamo(id) on delete cascade not null,
  usuario_id uuid references auth.users(id) not null,
  mensaje text not null,
  fecha timestamptz default now()
);

alter table recursos_prestamo enable row level security;
alter table mensajes_recurso enable row level security;

create policy "Ver recursos" on recursos_prestamo for select using (true);
create policy "Crear recursos" on recursos_prestamo for insert with check (auth.uid() = usuario_id);
create policy "Actualizar propios recursos" on recursos_prestamo for update using (auth.uid() = usuario_id);
create policy "Eliminar propios recursos" on recursos_prestamo for delete using (auth.uid() = usuario_id);

create policy "Ver mensajes recurso" on mensajes_recurso for select using (true);
create policy "Enviar mensaje recurso" on mensajes_recurso for insert with check (auth.uid() = usuario_id);
