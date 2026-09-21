-- Agregar columnas para donaciones de artículos a la tabla donaciones
alter table donaciones 
  add column if not exists tipo text not null default 'dinero' check (tipo in ('dinero', 'articulo')),
  add column if not exists articulo_descripcion text,
  add column if not exists cantidad integer;
