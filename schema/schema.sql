BEGIN TRANSACTION;

CREATE TABLE accounts (
  id uuid NOT NULL,

  enabled boolean NOT NULL,

  name text NOT NULL,

  PRIMARY KEY (id),

  CHECK (name <> '')
);

COMMIT TRANSACTION;
