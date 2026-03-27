-- ============================================================
-- Script de création de la base de données LiVrai
-- PostgreSQL 18
-- ============================================================

-- Création du type ENUM pour les statuts de livraison
CREATE TYPE delivery_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'DONE');

-- Table : role
CREATE TABLE IF NOT EXISTS role (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(64)  NOT NULL UNIQUE,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW()
    );

-- Données initiales : rôles (ordre important: CLIENT aura l'id 2)
INSERT INTO role (id, name) VALUES
    (1, 'ADMIN'),
    (2, 'CLIENT'),
    (3, 'SERVICE_COMMERCIAL'),
    (4, 'SERVICE_LIVRAISON');

-- Table : user
CREATE TABLE IF NOT EXISTS "user" (
    id         SERIAL PRIMARY KEY,
    email      VARCHAR(255) NOT NULL UNIQUE,
    name       VARCHAR(128) NOT NULL,
    password   VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    role_id    INT          NOT NULL DEFAULT 2,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES role(id)
    );

-- Table : address
CREATE TABLE IF NOT EXISTS address (
    id         SERIAL PRIMARY KEY,
    street     VARCHAR(255) NOT NULL,
    city       VARCHAR(128) NOT NULL,
    zip_code   VARCHAR(16)  NOT NULL,
    country    VARCHAR(64)  NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    user_id    INT          NOT NULL,
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES "user"(id)
    );

-- Table : command
CREATE TABLE IF NOT EXISTS command (
    id         SERIAL PRIMARY KEY,
    volume     INT          NOT NULL CHECK (volume > 0),
    weight     INT          NOT NULL CHECK (weight > 0),
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    user_id    INT          NOT NULL,
    address_id INT          NOT NULL,
    CONSTRAINT fk_command_user    FOREIGN KEY (user_id)    REFERENCES "user"(id),
    CONSTRAINT fk_command_address FOREIGN KEY (address_id) REFERENCES address(id)
    );

-- Table : delivery
CREATE TABLE IF NOT EXISTS delivery (
    id           SERIAL PRIMARY KEY,
    status       delivery_status NOT NULL DEFAULT 'PENDING',
    scheduled_at TIMESTAMP,
    created_at   TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP       NOT NULL DEFAULT NOW(),
    command_id   INT             NOT NULL UNIQUE,
    CONSTRAINT fk_delivery_command FOREIGN KEY (command_id) REFERENCES command(id)
    );

-- Table : bill
CREATE TABLE IF NOT EXISTS bill (
    id          SERIAL PRIMARY KEY,
    amount      DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    delivery_id INT           NOT NULL UNIQUE,
    CONSTRAINT fk_bill_delivery FOREIGN KEY (delivery_id) REFERENCES delivery(id)
    );

-- Index pour optimiser les recherches fréquentes
CREATE INDEX idx_user_email      ON "user"(email);
CREATE INDEX idx_user_role       ON "user"(role_id);
CREATE INDEX idx_command_user    ON command(user_id);
CREATE INDEX idx_delivery_status ON delivery(status);