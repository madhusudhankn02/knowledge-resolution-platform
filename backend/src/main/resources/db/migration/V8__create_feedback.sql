-- V8: customer feedback, one record per ticket.
-- The composite foreign key (ticket_id, customer_id) guarantees that the feedback author
-- is the customer who owns the ticket.

CREATE TABLE feedback (
    id          BIGINT GENERATED ALWAYS AS IDENTITY,
    ticket_id   BIGINT      NOT NULL,
    customer_id BIGINT      NOT NULL,
    rating      SMALLINT    NOT NULL,
    comment     VARCHAR(2000),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT pk_feedback PRIMARY KEY (id),
    CONSTRAINT uq_feedback_ticket UNIQUE (ticket_id),
    CONSTRAINT ck_feedback_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_feedback_ticket_owner FOREIGN KEY (ticket_id, customer_id)
        REFERENCES support_tickets (id, customer_id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
