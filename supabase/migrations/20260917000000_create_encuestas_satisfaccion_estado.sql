create table encuestas_satisfaccion_estado (
  usuario_id uuid primary key references auth.users(id) not null,
  last_shown_at timestamptz,
  last_completed_jornada_count_at_shown int default 0,
  respondida boolean default false,
  descartada boolean default false,
  updated_at timestamptz default now()
);

alter table encuestas_satisfaccion_estado enable row level security;

create policy "Ver propio estado de encuesta" on encuestas_satisfaccion_estado for select using (auth.uid() = usuario_id);
create policy "Insertar propio estado de encuesta" on encuestas_satisfaccion_estado for insert with check (auth.uid() = usuario_id);
create policy "Actualizar propio estado de encuesta" on encuestas_satisfaccion_estado for update using (auth.uid() = usuario_id);
