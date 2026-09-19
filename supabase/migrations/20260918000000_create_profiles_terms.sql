create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  terminos_aceptados_version int,
  terminos_aceptados_at timestamptz,
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Ver perfiles" on profiles for select using (true);
create policy "Actualizar propio perfil" on profiles for update using (auth.uid() = id);
create policy "Insertar propio perfil" on profiles for insert with check (auth.uid() = id);
