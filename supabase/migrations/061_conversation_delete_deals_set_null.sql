-- ============================================================
-- Allow conversation deletion without failing on linked deals.
--
-- deals.conversation_id was declared in 001_initial_schema.sql as:
--   conversation_id UUID REFERENCES conversations(id)
-- with Postgres's default ON DELETE NO ACTION. Deleting a
-- conversation that has ever been linked to a deal therefore fails
-- with SQLSTATE 23503 (foreign key violation).
--
-- SET NULL preserves the deal history while removing the deleted
-- conversation reference (matching 004_contact_delete_set_null.sql).
--
-- Idempotent — safe to run multiple times.
-- ============================================================

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'deals_conversation_id_fkey'
      AND conrelid = 'deals'::regclass
  ) THEN
    ALTER TABLE deals
      DROP CONSTRAINT deals_conversation_id_fkey;
  END IF;
END $$;

ALTER TABLE deals
  ADD CONSTRAINT deals_conversation_id_fkey
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
    ON DELETE SET NULL;
