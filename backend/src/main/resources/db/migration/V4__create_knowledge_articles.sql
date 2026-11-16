-- V4: knowledge-base articles with a generated full-text search column.

CREATE TABLE knowledge_articles (
    id           BIGINT GENERATED ALWAYS AS IDENTITY,
    title        VARCHAR(250) NOT NULL,
    summary      VARCHAR(500),
    content      TEXT         NOT NULL,
    category_id  BIGINT       NOT NULL,
    author_id    BIGINT       NOT NULL,
    status       VARCHAR(10)  NOT NULL DEFAULT 'DRAFT',
    view_count   INTEGER      NOT NULL DEFAULT 0,
    published_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version      BIGINT       NOT NULL DEFAULT 0,
    -- Maintained by PostgreSQL; not mapped in JPA, queried with native full-text search.
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', title || ' ' || coalesce(summary, '') || ' ' || content)) STORED,
    CONSTRAINT pk_knowledge_articles PRIMARY KEY (id),
    CONSTRAINT ck_articles_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT ck_articles_view_count CHECK (view_count >= 0),
    CONSTRAINT ck_articles_published_at CHECK (status <> 'PUBLISHED' OR published_at IS NOT NULL),
    CONSTRAINT fk_articles_category FOREIGN KEY (category_id)
        REFERENCES categories (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_articles_author FOREIGN KEY (author_id)
        REFERENCES users (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
