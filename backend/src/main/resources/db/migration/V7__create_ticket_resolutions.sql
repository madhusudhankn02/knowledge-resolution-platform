-- V7: resolution attempts. A ticket may have several attempts (e.g. after a reopen),
-- but at most one attempt can be current.

CREATE TABLE ticket_resolutions (
    id                 BIGINT GENERATED ALWAYS AS IDENTITY,
    ticket_id          BIGINT      NOT NULL,
    resolved_by        BIGINT      NOT NULL,
    article_id         BIGINT,
    resolution_summary TEXT        NOT NULL,
    attempt_number     INTEGER     NOT NULL,
    is_current         BOOLEAN     NOT NULL DEFAULT TRUE,
    resolved_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT pk_ticket_resolutions PRIMARY KEY (id),
    CONSTRAINT uq_resolutions_ticket_attempt UNIQUE (ticket_id, attempt_number),
    CONSTRAINT ck_resolutions_attempt CHECK (attempt_number > 0),
    CONSTRAINT ck_resolutions_summary_not_blank CHECK (length(btrim(resolution_summary)) > 0),
    CONSTRAINT fk_resolutions_ticket FOREIGN KEY (ticket_id)
        REFERENCES support_tickets (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_resolutions_resolver FOREIGN KEY (resolved_by)
        REFERENCES users (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_resolutions_article FOREIGN KEY (article_id)
        REFERENCES knowledge_articles (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);

-- At most one current resolution per ticket.
CREATE UNIQUE INDEX uq_resolutions_one_current_per_ticket ON ticket_resolutions (ticket_id) WHERE is_current;
