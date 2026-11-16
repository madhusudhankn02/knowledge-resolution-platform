-- V9: append-only audit trail of ticket activity. performed_by is NULL for system actions.

CREATE TABLE ticket_history (
    id           BIGINT GENERATED ALWAYS AS IDENTITY,
    ticket_id    BIGINT      NOT NULL,
    performed_by BIGINT,
    action_type  VARCHAR(30) NOT NULL,
    old_value    VARCHAR(100),
    new_value    VARCHAR(100),
    note         VARCHAR(1000),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT pk_ticket_history PRIMARY KEY (id),
    CONSTRAINT ck_history_action CHECK (action_type IN (
        'CREATED', 'STATUS_CHANGED', 'ASSIGNED', 'REASSIGNED', 'PRIORITY_CHANGED',
        'CATEGORY_CHANGED', 'RECOMMENDATION_ADDED', 'RESOLUTION_ADDED', 'FEEDBACK_SUBMITTED', 'REOPENED')),
    CONSTRAINT fk_history_ticket FOREIGN KEY (ticket_id)
        REFERENCES support_tickets (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_history_user FOREIGN KEY (performed_by)
        REFERENCES users (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
