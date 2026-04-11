#!/usr/bin/env python3
"""
One-time Supabase database setup — creates leads, outreach_log, companies
tables with indexes, triggers, and RLS via direct Postgres connection.

Requires: pip install psycopg2-binary
"""

import os
import sys
import json
import urllib.request
import urllib.error

try:
    import psycopg2
except ImportError:
    print("ERROR: psycopg2 not installed. Run: pip3 install psycopg2-binary")
    sys.exit(1)

DDL_STATEMENTS = [
    # Extension
    'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";',

    # Leads table
    """CREATE TABLE IF NOT EXISTS leads (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  linkedin_url    TEXT UNIQUE NOT NULL,
  email           TEXT,
  email_verified  BOOLEAN DEFAULT FALSE,
  name            TEXT,
  first_name      TEXT,
  last_name       TEXT,
  title           TEXT,
  company         TEXT,
  company_domain  TEXT,
  company_linkedin_url TEXT,
  company_headcount TEXT,
  industry        TEXT,
  location        TEXT,
  seniority_level TEXT,
  headline        TEXT,
  years_of_experience INTEGER,
  connections     INTEGER,
  skills          TEXT[],
  source          TEXT DEFAULT 'crustdata'
    CHECK (source IN ('crustdata', 'apollo', 'manual', 'linkedin', 'other')),
  client_name     TEXT,
  search_config_name TEXT,
  icp_segment     TEXT,
  date_found      TIMESTAMPTZ DEFAULT NOW(),
  enrichment_status TEXT DEFAULT 'complete'
    CHECK (enrichment_status IN ('pending', 'complete', 'failed', 'partial')),
  qualification_score NUMERIC,
  last_contacted  TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);""",

    # Leads indexes
    "CREATE INDEX IF NOT EXISTS idx_leads_linkedin_url ON leads (linkedin_url);",
    "CREATE INDEX IF NOT EXISTS idx_leads_client_name ON leads (client_name);",
    "CREATE INDEX IF NOT EXISTS idx_leads_last_contacted ON leads (last_contacted);",
    "CREATE INDEX IF NOT EXISTS idx_leads_source ON leads (source);",

    # Outreach log table
    """CREATE TABLE IF NOT EXISTS outreach_log (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lead_id               UUID REFERENCES leads(id) ON DELETE CASCADE,
  campaign_name         TEXT,
  smartlead_campaign_id TEXT,
  channel               TEXT DEFAULT 'email'
    CHECK (channel IN ('email', 'linkedin', 'phone', 'other')),
  sent_date             TIMESTAMPTZ,
  status                TEXT DEFAULT 'sent'
    CHECK (status IN ('sent', 'replied', 'bounced', 'opened', 'clicked', 'unsubscribed')),
  notes                 TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW()
);""",

    # Outreach log indexes
    "CREATE INDEX IF NOT EXISTS idx_outreach_lead_id ON outreach_log (lead_id);",
    "CREATE INDEX IF NOT EXISTS idx_outreach_campaign ON outreach_log (campaign_name);",

    # Companies table
    """CREATE TABLE IF NOT EXISTS companies (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  domain          TEXT UNIQUE,
  name            TEXT,
  linkedin_url    TEXT,
  headcount       INTEGER,
  headcount_range TEXT,
  industry        TEXT,
  company_type    TEXT,
  tech_stack      JSONB DEFAULT '[]'::jsonb,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);""",

    # Companies index
    "CREATE INDEX IF NOT EXISTS idx_companies_domain ON companies (domain);",

    # Updated_at trigger function
    """CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;""",

    # Triggers (use DROP + CREATE to be idempotent)
    "DROP TRIGGER IF EXISTS set_leads_updated_at ON leads;",
    """CREATE TRIGGER set_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();""",

    "DROP TRIGGER IF EXISTS set_companies_updated_at ON companies;",
    """CREATE TRIGGER set_companies_updated_at
  BEFORE UPDATE ON companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();""",

    # Row Level Security
    "ALTER TABLE leads ENABLE ROW LEVEL SECURITY;",
    "ALTER TABLE outreach_log ENABLE ROW LEVEL SECURITY;",
    "ALTER TABLE companies ENABLE ROW LEVEL SECURITY;",
]


def load_env():
    """Walk up from script dir looking for .env."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    d = script_dir
    for _ in range(5):
        env_path = os.path.join(d, ".env")
        if os.path.exists(env_path):
            env = {}
            with open(env_path) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        env[k.strip()] = v.strip().strip('"').strip("'")
            return env
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return {}


def get_connection_string(env):
    """Build Postgres connection string from env vars.

    Supabase direct connection: postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres
    If SUPABASE_DB_URL is set, use it directly. Otherwise construct from SUPABASE_URL + SUPABASE_DB_PASSWORD.
    """
    # Direct connection string takes priority
    if env.get("SUPABASE_DB_URL"):
        return env["SUPABASE_DB_URL"]

    # Construct from project URL + password
    supabase_url = env.get("SUPABASE_URL", "")
    db_password = env.get("SUPABASE_DB_PASSWORD", "")

    if not db_password:
        return None

    # Extract project ref from URL: https://fpzrtfcxgaywjhhaxqxu.supabase.co -> fpzrtfcxgaywjhhaxqxu
    import re
    match = re.search(r"https://([^.]+)\.supabase\.co", supabase_url)
    if not match:
        return None
    ref = match.group(1)

    return f"postgresql://postgres.{ref}:{db_password}@aws-0-us-east-1.pooler.supabase.com:6543/postgres"


def main():
    env = load_env()
    supabase_url = env.get("SUPABASE_URL", "")
    service_role_key = env.get("SUPABASE_SERVICE_ROLE_KEY", "")

    if not supabase_url or not service_role_key:
        print("ERROR: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env")
        sys.exit(1)

    conn_string = get_connection_string(env)
    if not conn_string:
        print("ERROR: Need a Postgres connection string.")
        print("  Add one of these to your .env:")
        print("    SUPABASE_DB_URL=postgresql://postgres.[ref]:[password]@...")
        print("    SUPABASE_DB_PASSWORD=your-database-password")
        sys.exit(1)

    print(f"Supabase URL: {supabase_url}")
    print(f"Connecting to Postgres...\n")

    try:
        conn = psycopg2.connect(conn_string)
        conn.autocommit = True
        cur = conn.cursor()
    except Exception as e:
        print(f"ERROR: Cannot connect to Postgres: {e}")
        sys.exit(1)

    print("Connected. Running DDL statements...\n")

    success = 0
    failed = 0
    for i, stmt in enumerate(DDL_STATEMENTS, 1):
        label = stmt.strip()[:70].replace("\n", " ")
        try:
            cur.execute(stmt)
            print(f"  [{i}/{len(DDL_STATEMENTS)}] OK: {label}...")
            success += 1
        except Exception as e:
            print(f"  [{i}/{len(DDL_STATEMENTS)}] FAIL: {label}...")
            print(f"    Error: {str(e).strip()[:200]}")
            failed += 1

    cur.close()
    conn.close()

    print(f"\nDDL complete: {success} succeeded, {failed} failed")

    if failed:
        print("\nSome statements failed. Check errors above.")
        sys.exit(1)

    # Verify tables via REST API
    print("\nVerifying tables via REST API...")
    for table in ["leads", "outreach_log", "companies"]:
        verify_url = f"{supabase_url.rstrip('/')}/rest/v1/{table}?select=id&limit=1"
        headers = {
            "apikey": service_role_key,
            "Authorization": f"Bearer {service_role_key}",
        }
        req = urllib.request.Request(verify_url, headers=headers, method="GET")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                print(f"  {table}: OK")
        except urllib.error.HTTPError as e:
            print(f"  {table}: ERROR ({e.code})")
        except Exception as e:
            print(f"  {table}: ERROR ({e})")

    print("\nDatabase setup complete.")


if __name__ == "__main__":
    main()
