-- V3: support tickets. Ticket numbers come from a sequence, so concurrent inserts never collide.
-- MAXVALUE keeps the number at 6 digits; the sequence errors loudly instead of wrapping.

CREATE SEQUENCE ticket_number_seq START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 999999 NO CYCLE;

CREATE TABLE support_tickets (
    id                BIGINT GENERATED ALWAYS AS IDENTITY,
    ticket_number     VARCHAR(20)  NOT NULL
        DEFAULT ('TKT-' || lpad(nextval('ticket_number_seq')::text, 6, '0')),
    subject           VARCHAR(200) NOT NULL,
    description       TEXT         NOT NULL,
    customer_id       BIGINT       NOT NULL,
    category_id       BIGINT       NOT NULL,
    assigned_agent_id BIGINT,
    priority          VARCHAR(10)  NOT NULL DEFAULT 'MEDIUM',
    status            VARCHAR(25)  NOT NULL DEFAULT 'OPEN',
    resolved_at       TIMESTAMPTZ,
    closed_at         TIMESTAMPTZ,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version           BIGINT       NOT NULL DEFAULT 0,
    CONSTRAINT pk_support_tickets PRIMARY KEY (id),
    CONSTRAINT uq_support_tickets_number UNIQUE (ticket_number),
    -- Target for the composite foreign key in feedback (guarantees feedback owner = ticket owner).
    CONSTRAINT uq_support_tickets_id_customer UNIQUE (id, customer_id),
    CONSTRAINT ck_tickets_number_format CHECK (ticket_number ~ '^TKT-[0-9]{6,}$'),
    CONSTRAINT ck_tickets_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    CONSTRAINT ck_tickets_status CHECK (status IN
        ('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'WAITING_ON_CUSTOMER', 'RESOLVED', 'CLOSED', 'REOPENED')),
    CONSTRAINT ck_tickets_agent_required CHECK (
        status NOT IN ('ASSIGNED', 'IN_PROGRESS', 'WAITING_ON_CUSTOMER') OR assigned_agent_id IS NOT NULL),
    CONSTRAINT ck_tickets_resolved_after_created CHECK (resolved_at IS NULL OR resolved_at >= created_at),
    CONSTRAINT fk_tickets_customer FOREIGN KEY (customer_id)
        REFERENCES customers (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_tickets_category FOREIGN KEY (category_id)
        REFERENCES categories (id) ON DELETE RESTRICT ON UPDATE NO ACTION,
    -- The AGENT-role rule is enforced in the service layer.
    CONSTRAINT fk_tickets_agent FOREIGN KEY (assigned_agent_id)
        REFERENCES users (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
