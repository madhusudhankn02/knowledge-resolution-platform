-- READ-ONLY structure checks for M2 Phase C. Safe to run in pgAdmin Query Tool.
-- 1) Exactly 11 business tables (flyway_schema_history is Flyway's own table).
SELECT count(*) AS business_tables_expected_11
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE' AND table_name <> 'flyway_schema_history';

-- 2) Primary keys: one per table (expected 11 rows).
SELECT tc.table_name, string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) AS pk_columns
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name)
WHERE tc.table_schema = 'public' AND tc.constraint_type = 'PRIMARY KEY'
GROUP BY tc.table_name ORDER BY tc.table_name;

-- 3) Foreign keys with delete rules (expected 16 rows).
SELECT conrelid::regclass AS child_table, conname, confrelid::regclass AS parent_table,
       CASE confdeltype WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE' WHEN 'a' THEN 'NO ACTION' END AS on_delete
FROM pg_constraint WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, conname;

-- 4) CHECK constraints (expected 20 rows).
SELECT conrelid::regclass AS table_name, conname FROM pg_constraint
WHERE contype = 'c' AND connamespace = 'public'::regnamespace ORDER BY conrelid::regclass::text, conname;

-- 5) Indexes (expected 35 rows including PK/unique indexes).
SELECT tablename, indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;

-- 6) Identity columns and timestamp types.
SELECT table_name, column_name, is_identity, identity_generation FROM information_schema.columns
WHERE table_schema = 'public' AND column_name = 'id' ORDER BY table_name;
SELECT table_name, column_name, data_type FROM information_schema.columns
WHERE table_schema = 'public' AND column_name LIKE '%\_at' AND data_type <> 'timestamp with time zone';  -- expected 0 rows

-- 7) Flyway history (after the application has started once).
-- SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;
