-- V5: reusable tags and the many-to-many link table.

CREATE TABLE article_tags (
    id         BIGINT GENERATED ALWAYS AS IDENTITY,
    name       VARCHAR(50)  NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT pk_article_tags PRIMARY KEY (id),
    CONSTRAINT ck_article_tags_name_not_blank CHECK (length(btrim(name)) > 0)
);

CREATE UNIQUE INDEX uq_article_tags_name_lower ON article_tags (lower(name));

-- Link rows only: cascading from article/tag deletion removes mappings, never business records.
CREATE TABLE article_tag_mappings (
    article_id BIGINT NOT NULL,
    tag_id     BIGINT NOT NULL,
    CONSTRAINT pk_article_tag_mappings PRIMARY KEY (article_id, tag_id),
    CONSTRAINT fk_atm_article FOREIGN KEY (article_id)
        REFERENCES knowledge_articles (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_atm_tag FOREIGN KEY (tag_id)
        REFERENCES article_tags (id) ON DELETE CASCADE ON UPDATE NO ACTION
);
