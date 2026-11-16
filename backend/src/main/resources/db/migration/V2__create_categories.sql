-- V2: categories shared by tickets and knowledge articles.

CREATE TABLE categories (
    id          BIGINT GENERATED ALWAYS AS IDENTITY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT pk_categories PRIMARY KEY (id),
    CONSTRAINT ck_categories_name_not_blank CHECK (length(btrim(name)) > 0)
);

CREATE UNIQUE INDEX uq_categories_name_lower ON categories (lower(name));
