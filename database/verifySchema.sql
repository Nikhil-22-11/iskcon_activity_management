-- ISKCON Activity Management System - Database Verification Script
-- Run against the iskcon_activity_db database to verify the schema is correct.
-- Usage: psql -U postgres -d iskcon_activity_db -f database/verifySchema.sql

\echo '=================================================================='
\echo ' ISKCON Activity Management - Database Schema Verification'
\echo '=================================================================='

-- ─── 1. Check all required tables exist ───────────────────────────────────────

\echo ''
\echo '-- 1. Checking required tables...'

DO $$
DECLARE
    required_tables TEXT[] := ARRAY[
        'users', 'students', 'activities', 'enrollments',
        'attendance', 'enquiries', 'visitors'
    ];
    tbl TEXT;
    missing INTEGER := 0;
BEGIN
    FOREACH tbl IN ARRAY required_tables LOOP
        IF to_regclass('public.' || tbl) IS NULL THEN
            RAISE WARNING 'MISSING TABLE: %', tbl;
            missing := missing + 1;
        ELSE
            RAISE NOTICE 'OK - Table exists: %', tbl;
        END IF;
    END LOOP;

    IF missing = 0 THEN
        RAISE NOTICE 'All % required tables exist.', array_length(required_tables, 1);
    ELSE
        RAISE EXCEPTION '% table(s) are missing from the schema!', missing;
    END IF;
END;
$$;

-- ─── 2. Check column presence on critical tables ──────────────────────────────

\echo ''
\echo '-- 2. Checking critical columns...'

DO $$
DECLARE
    col_exists BOOLEAN;

    PROCEDURE check_column(p_table TEXT, p_column TEXT) AS $$
    DECLARE
        exists_flag BOOLEAN;
    BEGIN
        SELECT TRUE INTO exists_flag
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name   = p_table
          AND column_name  = p_column;
        IF NOT FOUND THEN
            RAISE WARNING 'MISSING COLUMN: %.%', p_table, p_column;
        ELSE
            RAISE NOTICE 'OK - %.% exists', p_table, p_column;
        END IF;
    END;
    $$;
BEGIN
    -- users
    CALL check_column('users', 'id');
    CALL check_column('users', 'email');
    CALL check_column('users', 'password_hash');
    CALL check_column('users', 'role');
    CALL check_column('users', 'is_active');
    CALL check_column('users', 'must_change_password');

    -- students
    CALL check_column('students', 'id');
    CALL check_column('students', 'student_id');
    CALL check_column('students', 'name');
    CALL check_column('students', 'qr_code');
    CALL check_column('students', 'is_active');

    -- activities
    CALL check_column('activities', 'id');
    CALL check_column('activities', 'name');
    CALL check_column('activities', 'schedule');
    CALL check_column('activities', 'is_active');

    -- enrollments
    CALL check_column('enrollments', 'student_id');
    CALL check_column('enrollments', 'activity_id');
    CALL check_column('enrollments', 'is_active');

    -- attendance
    CALL check_column('attendance', 'student_id');
    CALL check_column('attendance', 'activity_id');
    CALL check_column('attendance', 'check_in_time');
    CALL check_column('attendance', 'status');

    -- enquiries
    CALL check_column('enquiries', 'name');
    CALL check_column('enquiries', 'message');
    CALL check_column('enquiries', 'status');

    -- visitors
    CALL check_column('visitors', 'name');
    CALL check_column('visitors', 'purpose');
    CALL check_column('visitors', 'check_in_time');
    CALL check_column('visitors', 'check_out_time');
    CALL check_column('visitors', 'status');
END;
$$;

-- ─── 3. Verify foreign key constraints ────────────────────────────────────────

\echo ''
\echo '-- 3. Checking foreign key constraints...'

SELECT
    tc.table_name        AS "Table",
    kcu.column_name      AS "Column",
    ccu.table_name       AS "References Table",
    ccu.column_name      AS "References Column"
FROM information_schema.table_constraints   AS tc
JOIN information_schema.key_column_usage    AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema    = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
   AND ccu.table_schema    = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema    = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- ─── 4. Verify performance indexes ────────────────────────────────────────────

\echo ''
\echo '-- 4. Checking performance indexes...'

SELECT
    indexname   AS "Index Name",
    tablename   AS "Table",
    indexdef    AS "Definition"
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ─── 5. Verify default admin user ─────────────────────────────────────────────

\echo ''
\echo '-- 5. Checking default admin user...'

DO $$
DECLARE
    admin_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO admin_count
    FROM users
    WHERE email = 'admin@iskcon.org'
      AND role  = 'admin';

    IF admin_count = 0 THEN
        RAISE EXCEPTION 'Default admin user admin@iskcon.org NOT FOUND!';
    ELSE
        RAISE NOTICE 'OK - Default admin user admin@iskcon.org exists (% row(s))', admin_count;
    END IF;
END;
$$;

-- ─── 6. Row counts summary ────────────────────────────────────────────────────

\echo ''
\echo '-- 6. Row counts per table:'

SELECT 'users'       AS "Table", COUNT(*) AS "Rows" FROM users
UNION ALL
SELECT 'students',     COUNT(*) FROM students
UNION ALL
SELECT 'activities',   COUNT(*) FROM activities
UNION ALL
SELECT 'enrollments',  COUNT(*) FROM enrollments
UNION ALL
SELECT 'attendance',   COUNT(*) FROM attendance
UNION ALL
SELECT 'enquiries',    COUNT(*) FROM enquiries
UNION ALL
SELECT 'visitors',     COUNT(*) FROM visitors
ORDER BY "Table";

\echo ''
\echo '=================================================================='
\echo ' Verification complete.'
\echo '=================================================================='
