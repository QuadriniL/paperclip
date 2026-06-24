-- Hotfix: repair environments schema when migration 0065+ drifted on an older volume.
--
-- Usage (inside Paperclip container):
--   node /app/scripts/ops/run-hotfix-environments-schema.mjs
--   # or: pnpm db:hotfix-environments
--
-- Then restart Paperclip. With PAPERCLIP_MIGRATION_AUTO_APPLY=true, remaining
-- migrations apply idempotently on boot.

-- Broken/partial environments tables block CREATE IF NOT EXISTS — drop and recreate.
DROP TABLE IF EXISTS environment_leases CASCADE;
DROP TABLE IF EXISTS environments CASCADE;

CREATE TABLE "environments" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "company_id" uuid NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "driver" text DEFAULT 'local' NOT NULL,
  "status" text DEFAULT 'active' NOT NULL,
  "config" jsonb DEFAULT '{}'::jsonb NOT NULL,
  "metadata" jsonb,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "environment_leases" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "company_id" uuid NOT NULL,
  "environment_id" uuid NOT NULL,
  "execution_workspace_id" uuid,
  "issue_id" uuid,
  "heartbeat_run_id" uuid,
  "status" text DEFAULT 'active' NOT NULL,
  "lease_policy" text DEFAULT 'ephemeral' NOT NULL,
  "provider" text,
  "provider_lease_id" text,
  "acquired_at" timestamp with time zone DEFAULT now() NOT NULL,
  "last_used_at" timestamp with time zone DEFAULT now() NOT NULL,
  "expires_at" timestamp with time zone,
  "released_at" timestamp with time zone,
  "failure_reason" text,
  "cleanup_status" text,
  "metadata" jsonb,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "environments"
  ADD CONSTRAINT "environments_company_id_companies_id_fk"
  FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id")
  ON DELETE cascade ON UPDATE no action;

ALTER TABLE "environment_leases"
  ADD CONSTRAINT "environment_leases_company_id_companies_id_fk"
  FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id")
  ON DELETE cascade ON UPDATE no action;

ALTER TABLE "environment_leases"
  ADD CONSTRAINT "environment_leases_environment_id_environments_id_fk"
  FOREIGN KEY ("environment_id") REFERENCES "public"."environments"("id")
  ON DELETE cascade ON UPDATE no action;

CREATE INDEX "environments_company_status_idx"
  ON "environments" USING btree ("company_id","status");
CREATE INDEX "environments_company_name_idx"
  ON "environments" USING btree ("company_id","name");

CREATE UNIQUE INDEX "environments_company_driver_idx"
  ON "environments" USING btree ("company_id","driver")
  WHERE "driver" = 'local';

ALTER TABLE "agents" ADD COLUMN IF NOT EXISTS "default_environment_id" uuid;
CREATE INDEX IF NOT EXISTS "agents_company_default_environment_idx"
  ON "agents" USING btree ("company_id","default_environment_id");

INSERT INTO environments (company_id, name, description, driver, status, config, metadata, created_at, updated_at)
SELECT
  c.id,
  'Local',
  'Default execution environment for Paperclip runs on this machine.',
  'local',
  'active',
  '{}'::jsonb,
  '{"managedByPaperclip":true,"defaultForCompany":true}'::jsonb,
  NOW(),
  NOW()
FROM companies c;
