create table if not exists articles (
    id text primary key,
    content  text not null,
    created  text not null,
    title  text not null
);
