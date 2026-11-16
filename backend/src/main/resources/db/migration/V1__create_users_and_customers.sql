-- V1: user accounts and customer profiles.

CREATE TABLE users (
    id            BIGINT GENERATED ALWAYS AS IDENTITY,
    email         VARCHAR(255) NOT NULL,
    full_name     VARCHAR(150) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    role          VARCHAR(20)  NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version       BIGINT       NOT NULL DEFAULT 0,
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT ck_users_role CHECK (role IN ('CUSTOMER', 'AGENT', 'ADMIN')),
    CONSTRAINT ck_users_email_format CHECK (position('@' IN email) > 1),
    -- Only a BCrypt hash, or '!' (account cannot log in), may be stored. Plaintext is rejected.
    CONSTRAINT ck_users_password_hash CHECK (
        password_hash = '!' OR password_hash ~ '^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$')
);

-- Case-insensitive unique email.
CREATE UNIQUE INDEX uq_users_email_lower ON users (lower(email));

CREATE TABLE customers (
    id           BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id      BIGINT       NOT NULL,
    phone        VARCHAR(30),
    company_name VARCHAR(150),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version      BIGINT       NOT NULL DEFAULT 0,
    CONSTRAINT pk_customers PRIMARY KEY (id),
    -- One profile per user. The CUSTOMER-role rule is enforced in the service layer.
    CONSTRAINT uq_customers_user UNIQUE (user_id),
    CONSTRAINT fk_customers_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT ON UPDATE NO ACTION
);
