-- Users table
create table if not exists public.users (
    id uuid primary key default uuid_generate_v4(),
    email text unique not null,
    created_at timestamptz default now(),
    age integer,
    gender text
);

-- Scans table
create table if not exists public.scans (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references public.users(id) on delete cascade,
    image_url text,
    prediction text not null,
    confidence double precision not null,
    created_at timestamptz default now()
);

create index if not exists scans_user_id_idx on public.scans(user_id);
