-- Postgres (Supabase). Rode uma vez no SQL Editor.
-- Se a tabela já existir, não rode o CREATE de novo.
-- Os dados de exemplo estão em seed_sp.sql.

create table cidade (
  id bigint generated always as identity primary key,
  nome text not null,
  uf text not null,
  cod_ibge integer not null unique
);

create table bairro (
  id bigint generated always as identity primary key,
  cidade_id bigint not null references cidade (id),
  nome text not null,
  latitude double precision not null,
  longitude double precision not null
);

create table tipo_crime (
  id bigint generated always as identity primary key,
  codigo text not null unique,
  nome text not null
);

create table indicador_criminalidade (
  id bigint generated always as identity primary key,
  bairro_id bigint not null references bairro (id),
  tipo_crime_id bigint not null references tipo_crime (id),
  quantidade integer not null check (quantidade >= 0),
  periodo_inicio date not null,
  periodo_fim date not null,
  unique (bairro_id, tipo_crime_id, periodo_inicio, periodo_fim)
);

create table plano (
  usuario_id uuid primary key references auth.users (id) on delete cascade,
  eh_pro boolean not null default false,
  ja_usou_relatorio_gratis boolean not null default false
);

alter table cidade enable row level security;
alter table bairro enable row level security;
alter table tipo_crime enable row level security;
alter table indicador_criminalidade enable row level security;
alter table plano enable row level security;

create policy "leitura da cidade" on cidade
  for select to authenticated using (true);
create policy "leitura dos bairros" on bairro
  for select to authenticated using (true);
create policy "leitura dos tipos" on tipo_crime
  for select to authenticated using (true);
create policy "leitura dos indicadores" on indicador_criminalidade
  for select to authenticated using (true);

create policy "le o proprio plano" on plano
  for select to authenticated using (usuario_id = auth.uid());
create policy "cria o proprio plano" on plano
  for insert to authenticated with check (usuario_id = auth.uid());
create policy "atualiza o proprio plano" on plano
  for update to authenticated using (usuario_id = auth.uid());
