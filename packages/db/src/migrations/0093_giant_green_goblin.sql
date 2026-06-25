ALTER TABLE "execution_workspaces" DROP CONSTRAINT IF EXISTS "execution_workspaces_company_id_companies_id_fk";--> statement-breakpoint
ALTER TABLE "workspace_operations" DROP CONSTRAINT IF EXISTS "workspace_operations_company_id_companies_id_fk";--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'execution_workspaces_company_id_companies_id_fk') THEN
  ALTER TABLE "execution_workspaces" ADD CONSTRAINT "execution_workspaces_company_id_companies_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE cascade ON UPDATE no action;
 END IF;
END $$;--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'workspace_operations_company_id_companies_id_fk') THEN
  ALTER TABLE "workspace_operations" ADD CONSTRAINT "workspace_operations_company_id_companies_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE cascade ON UPDATE no action;
 END IF;
END $$;
