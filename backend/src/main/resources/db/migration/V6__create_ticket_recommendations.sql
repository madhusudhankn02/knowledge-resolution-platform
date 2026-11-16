-- V6: articles recommended for a ticket (by the system or an agent).

CREATE TABLE ticket_recommendations (
    id              BIGINT GENERATED ALWAYS AS IDENTITY,
    ticket_id       BIGINT        NOT NULL,
    article_id      BIGINT        NOT NULL,
    relevance_score NUMERIC(5, 4) NOT NULL,
    rank_position   SMALLINT      NOT NULL,
    source          VARCHAR(10)   NOT NULL DEFAULT 'SYSTEM',
    is_helpful      BOOLEAN,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT pk_ticket_recommendations PRIMARY KEY (id),
    CONSTRAINT uq_recommendations_ticket_article UNIQUE (ticket_id, article_id),
    CONSTRAINT ck_recommendations_score CHECK (relevance_score BETWEEN 0 AND 1),
    CONSTRAINT ck_recommendations_rank CHECK (rank_position > 0),
    CONSTRAINT ck_recommendations_source CHECK (source IN ('SYSTEM', 'AGENT')),
    CONSTRAINT fk_recommendations_ticket FOREIGN KEY (ticket_id)
        REFERENCES support_tickets (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_recommendations_article FOREIGN KEY (article_id)
        REFERENCES knowledge_articles (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
