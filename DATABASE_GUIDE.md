# ISKCON Activity Management System — Database Guide

> This guide explains **where data lives, how it gets there, and how to inspect it** at every layer of the stack.

---

## Table of Contents

1. [Data Architecture Overview](#1-data-architecture-overview)
2. [Layer A — Mock In-Memory Data (always available)](#2-layer-a--mock-in-memory-data-always-available)
3. [Layer B — PostgreSQL Backend (optional, for production)](#3-layer-b--postgresql-backend-optional-for-production)
4. [Database Schema — All Tables](#4-database-schema--all-tables)
5. [How to Set Up the Real Database](#5-how-to-set-up-the-real-database)
6. [How to Inspect Data — Step-by-Step](#6-how-to-inspect-data--step-by-step)
   - [Option 1: psql command-line](#61-option-1-psql-command-line)
   - [Option 2: pgAdmin GUI](#62-option-2-pgadmin-gui)
   - [Option 3: Backend API endpoints](#63-option-3-backend-api-endpoints)
   - [Option 4: Automated test script](#64-option-4-automated-test-script)
7. [Useful Verification Queries](#7-useful-verification-queries)
8. [How New Data Enters the System](#8-how-new-data-enters-the-system)
9. [Seed Data Reference](#9-seed-data-reference)
10. [Environment Variables Reference](#10-environment-variables-reference)

---

## 1. Data Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter App                           │
│                                                          │
│  ApiService.someMethod()                                 │
│       │                                                  │
│       ├─ isMockToken? ──YES──► MockDataService           │
│       │                        (in-memory, always works) │
│       │                                                  │
│       └─ NO ─► HTTP ──► Node.js/Express (port 5000)      │
│                               │                          │
│                               └─► PostgreSQL             │
│                                   iskcon_activity_db     │
└──────────────────────────────────────────────────────────┘
```

### Which layer is active right now?

| Scenario | Active Layer | Where data lives |
|----------|-------------|-----------------|
| App launched, no backend running | **Mock** | RAM (lost on restart) |
| Backend running, valid JWT | **PostgreSQL** | `iskcon_activity_db` on disk |
| Backend running, mock token used | **Mock** | RAM |

**During development / demos:** The app uses **mock data only**.  
**In production:** Run the backend (`npm run dev`) and the app will automatically use PostgreSQL.

---

## 2. Layer A — Mock In-Memory Data (always available)

### File location
`flutter_app/lib/services/mock_data_service.dart`

### What is stored in mock memory?

| Collection | Count | How to add more |
|------------|-------|----------------|
| Students | 22 | Add `StudentModel(...)` entries to `_students` list in the file |
| Activities | 10 | Add `ActivityModel(...)` entries to `_activities` list |
| Attendance records | 7 | Add `AttendanceModel(...)` entries to `_attendance` list |
| Visitors | 3 | Add `VisitorModel(...)` entries to `_visitors` list |
| QR scan history | 6 | Add entries to `_qrScanHistory` list |
| Admissions | 0 (grows at runtime) | Submitted via Admission Form; `_admissions` list |
| Enrollments | Map per activity | Edit `_enrollmentMap` dictionary |

### How to see mock data at runtime
There is no database GUI for mock data — it exists only in memory while the app is running.  
**To inspect it:** add a `print()` or `debugPrint()` statement in the Dart code and run the app, then check the **Flutter console output** (the terminal where you ran `flutter run`).

Example — print all mock students:
```dart
// Temporary debug line, add inside any screen's initState():
MockDataService().getStudents().forEach((s) => debugPrint(s.name));
```

### Lifetime of mock data
Mock data is **reset every time the app is restarted**.  
Admissions and new students added during a session are lost on next launch.

---

## 3. Layer B — PostgreSQL Backend (optional, for production)

### File location
`backend/config/db.js`

```js
const { Pool } = require('pg');
const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});
```

Data persists on disk and survives app restarts.  
All CRUD operations go through the backend API; the Flutter app never connects to the database directly.

---

## 4. Database Schema — All Tables

The schema file lives at `backend/database/schema.sql`.

### `users` — Staff accounts (teachers, guards, principals)

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | Auto-increment |
| `name` | VARCHAR(100) | Full name |
| `email` | VARCHAR(150) UNIQUE | Login email |
| `password_hash` | VARCHAR(255) | bcrypt hash |
| `role` | VARCHAR(20) | `admin` / `teacher` / `guard` / `principal` |
| `is_active` | BOOLEAN | Default `true` |
| `must_change_password` | BOOLEAN | Default `true` |
| `last_login` | TIMESTAMP | Updated on each login |
| `created_at` | TIMESTAMP | Auto |
| `updated_at` | TIMESTAMP | Auto |

### `students` — Enrolled children

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `student_id` | VARCHAR(20) UNIQUE | Code like `STU001` |
| `name` | VARCHAR(100) | |
| `email` | VARCHAR(150) | |
| `phone` | VARCHAR(15) | |
| `parent_name` | VARCHAR(100) | |
| `parent_phone` | VARCHAR(15) | |
| `class_name` | VARCHAR(50) | |
| `section` | VARCHAR(10) | |
| `address` | TEXT | |
| `date_of_birth` | DATE | |
| `photo_url` | TEXT | |
| `qr_code` | TEXT | Base64 QR image |
| `is_active` | BOOLEAN | Default `true` |
| `created_at` / `updated_at` | TIMESTAMP | Auto |

### `activities` — After-school programs

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `name` | VARCHAR(150) | e.g., "Swimming" |
| `description` | TEXT | |
| `type` | VARCHAR(50) | `spiritual` / `academic` / `arts` / `wellness` / `service` |
| `location` | VARCHAR(150) | |
| `schedule` | VARCHAR(100) | e.g., "Mon, Wed, Fri - 7:00 AM" |
| `start_date` / `end_date` | DATE | |
| `max_students` | INTEGER | Capacity |
| `is_active` | BOOLEAN | |
| `created_by` | FK → `users.id` | |
| `created_at` / `updated_at` | TIMESTAMP | |

### `enrollments` — Which student is in which activity

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `student_id` | FK → `students.id` | |
| `activity_id` | FK → `activities.id` | |
| `enrolled_at` | TIMESTAMP | Default NOW() |
| `enrolled_by` | FK → `users.id` | |
| `is_active` | BOOLEAN | |
| UNIQUE | `(student_id, activity_id)` | Prevents duplicate enrollment |

### `attendance` — Check-in / check-out records

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `student_id` | FK → `students.id` | |
| `activity_id` | FK → `activities.id` | |
| `check_in_time` | TIMESTAMP | Default NOW() |
| `check_out_time` | TIMESTAMP | Null until checked out |
| `status` | VARCHAR(20) | `present` / `absent` / `late` |
| `marked_by` | FK → `users.id` | |
| `notes` | TEXT | |
| `created_at` | TIMESTAMP | |

### `enquiries` — Admission/information enquiries

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `name` | VARCHAR(100) | |
| `email` / `phone` | VARCHAR | |
| `message` | TEXT | |
| `source` | VARCHAR(50) | `website` / `phone` / `walk-in` |
| `status` | VARCHAR(20) | `new` / `in_progress` / `resolved` / `closed` |
| `notes` | TEXT | Internal notes |
| `assigned_to` | FK → `users.id` | |
| `created_at` / `updated_at` | TIMESTAMP | |

### `visitors` — Gate check-in log

| Column | Type | Notes |
|--------|------|-------|
| `id` | SERIAL PK | |
| `name` | VARCHAR(100) | Visitor's name |
| `phone` | VARCHAR(15) | |
| `purpose` | TEXT | |
| `host_name` | VARCHAR(100) | Who they are visiting |
| `id_type` / `id_number` | VARCHAR | Aadhar / driving licence etc. |
| `photo_url` | TEXT | |
| `check_in_time` | TIMESTAMP | Default NOW() |
| `check_out_time` | TIMESTAMP | Null until checked out |
| `status` | VARCHAR(20) | `checked_in` / `checked_out` |
| `notes` | TEXT | |
| `checked_in_by` | FK → `users.id` | Guard who processed |
| `created_at` / `updated_at` | TIMESTAMP | |

### Performance Indexes

```sql
idx_students_student_id        ON students(student_id)
idx_students_name              ON students(name)
idx_attendance_student_id      ON attendance(student_id)
idx_attendance_check_in_time   ON attendance(check_in_time)
idx_attendance_activity_id     ON attendance(activity_id)
idx_enrollments_student_id     ON enrollments(student_id)
idx_enrollments_activity_id    ON enrollments(activity_id)
idx_visitors_check_in_time     ON visitors(check_in_time)
idx_enquiries_status           ON enquiries(status)
```

---

## 5. How to Set Up the Real Database

### Prerequisites
- PostgreSQL 14 or higher installed
- `psql` available in PATH

### Step 1 — Create the database
```bash
psql -U postgres -c "CREATE DATABASE iskcon_activity_db;"
```

### Step 2 — Apply the schema
```bash
psql -U postgres -d iskcon_activity_db -f backend/database/schema.sql
```

This creates all 7 tables, indexes, and a default admin user.

### Step 3 — (Optional) Load sample data
```bash
psql -U postgres -d iskcon_activity_db -f backend/database/seed.sql
```

### Step 4 — Configure the backend
```bash
cd backend
cp .env.example .env
# Edit .env:
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=iskcon_activity_db
# DB_USER=postgres
# DB_PASSWORD=<your password>
# JWT_SECRET=<long random string>
# PORT=5000
```

### Step 5 — Start the backend
```bash
cd backend
npm install
npm run dev
```

Verify it is running:
```bash
curl http://localhost:5000/health
```
Expected:
```json
{ "success": true, "message": "ISKCON Activity Management API is running" }
```

---

## 6. How to Inspect Data — Step-by-Step

### 6.1 Option 1: psql command-line

Open a terminal and connect:
```bash
psql -U postgres -d iskcon_activity_db
```

Useful commands inside psql:
```sql
-- List all tables
\dt

-- Count rows in each table
SELECT 'users'       AS tbl, COUNT(*) FROM users
UNION ALL SELECT 'students',    COUNT(*) FROM students
UNION ALL SELECT 'activities',  COUNT(*) FROM activities
UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments
UNION ALL SELECT 'attendance',  COUNT(*) FROM attendance
UNION ALL SELECT 'visitors',    COUNT(*) FROM visitors
UNION ALL SELECT 'enquiries',   COUNT(*) FROM enquiries;

-- View all students
SELECT id, student_id, name, email, phone FROM students ORDER BY id;

-- View recent attendance (last 10)
SELECT a.id, s.name AS student, ac.name AS activity,
       a.check_in_time, a.status
FROM   attendance a
JOIN   students   s  ON s.id  = a.student_id
JOIN   activities ac ON ac.id = a.activity_id
ORDER  BY a.check_in_time DESC
LIMIT  10;

-- Quit psql
\q
```

### 6.2 Option 2: pgAdmin GUI

1. Download and install **pgAdmin 4** from https://www.pgadmin.org/download/
2. Open pgAdmin → add a server:
   - Host: `localhost`
   - Port: `5432`
   - Database: `iskcon_activity_db`
   - Username: `postgres`
   - Password: (your password)
3. Expand **Schemas → public → Tables**
4. Right-click any table → **View/Edit Data → All Rows**

### 6.3 Option 3: Backend API endpoints

Start the backend (`npm run dev`), then call the API:

```bash
# 1. Get a JWT token
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@iskcon.org","password":"Admin@123"}'
# Copy the token from the response

TOKEN="<paste token here>"

# 2. List all students
curl http://localhost:5000/api/students \
  -H "Authorization: Bearer $TOKEN"

# 3. List all activities
curl http://localhost:5000/api/activities \
  -H "Authorization: Bearer $TOKEN"

# 4. View today's attendance
DATE=$(date +%Y-%m-%d)
curl "http://localhost:5000/api/attendance/date/$DATE" \
  -H "Authorization: Bearer $TOKEN"

# 5. View all visitors
curl http://localhost:5000/api/visitors \
  -H "Authorization: Bearer $TOKEN"

# 6. Dashboard stats (principal view)
curl http://localhost:5000/api/dashboard/principal \
  -H "Authorization: Bearer $TOKEN"
```

All responses follow the format:
```json
{
  "success": true,
  "message": "...",
  "data": [ ... ],
  "pagination": { "total": 22, "page": 1, "limit": 20 }
}
```

### 6.4 Option 4: Automated test script

The repo includes a Node.js test script that verifies the database and all API endpoints:

```bash
# Ensure backend is running, then:
cd <repo root>
node tests/testAPI.js
```

Expected output:
```
╔══════════════════════════════════════════════════════════╗
║   ISKCON Activity Management - API Test Suite            ║
╚══════════════════════════════════════════════════════════╝

📦 1. Database Connection
  ✅  PostgreSQL connection established
  ✅  Table 'users' exists
  ✅  Table 'students' exists
  ✅  Table 'activities' exists
  ✅  Table 'enrollments' exists
  ✅  Table 'attendance' exists
  ✅  Table 'visitors' exists
  ✅  Table 'enquiries' exists

✅ All tests passed!
```

You can also run **Postman** collection from `postman/` directory:
1. Open Postman → Import → select `postman/ISKCON_Activity_Management.postman_collection.json`
2. Import the environment file if present
3. Click **Run collection**

---

## 7. Useful Verification Queries

Copy-paste these into `psql` or pgAdmin to verify specific data:

```sql
-- 1. Confirm all 7 tables exist
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- 2. See all users and their roles
SELECT id, name, email, role, is_active, last_login FROM users ORDER BY role;

-- 3. Students enrolled in more than one activity
SELECT s.name, COUNT(e.activity_id) AS activities_count
FROM   students s
JOIN   enrollments e ON e.student_id = s.id
WHERE  e.is_active = true
GROUP  BY s.name
HAVING COUNT(e.activity_id) > 1
ORDER  BY activities_count DESC;

-- 4. Activity enrollment summary
SELECT a.name, COUNT(e.id) AS enrolled, a.max_students AS capacity
FROM   activities a
LEFT   JOIN enrollments e ON e.activity_id = a.id AND e.is_active = true
GROUP  BY a.name, a.max_students
ORDER  BY enrolled DESC;

-- 5. Attendance summary for today
SELECT s.name, ac.name AS activity, att.status, att.check_in_time
FROM   attendance att
JOIN   students   s  ON s.id  = att.student_id
JOIN   activities ac ON ac.id = att.activity_id
WHERE  DATE(att.check_in_time) = CURRENT_DATE
ORDER  BY att.check_in_time;

-- 6. Visitors currently on premises (checked in, not yet out)
SELECT name, phone, purpose, check_in_time
FROM   visitors
WHERE  status = 'checked_in'
ORDER  BY check_in_time;

-- 7. Enquiries by status
SELECT status, COUNT(*) FROM enquiries GROUP BY status;

-- 8. Verify schema version (row counts)
SELECT
  (SELECT COUNT(*) FROM users)       AS users,
  (SELECT COUNT(*) FROM students)    AS students,
  (SELECT COUNT(*) FROM activities)  AS activities,
  (SELECT COUNT(*) FROM enrollments) AS enrollments,
  (SELECT COUNT(*) FROM attendance)  AS attendance,
  (SELECT COUNT(*) FROM visitors)    AS visitors,
  (SELECT COUNT(*) FROM enquiries)   AS enquiries;
```

---

## 8. How New Data Enters the System

### Mock mode (no backend)

| Action | What happens |
|--------|-------------|
| Submit Admission Form | `MockDataService().addAdmission(data)` — added to `_admissions` list in RAM |
| Guard scans QR | `MockDataService().addQrScan(payload)` — added to `_qrScanHistory` in RAM |
| Teacher adds student | `MockDataService().addStudent(data)` — added to `_students` list in RAM |

### Backend connected mode

| Action | API call | DB table updated |
|--------|----------|-----------------|
| Submit Admission Form | `POST /api/admissions` | `enquiries` (stored as an enquiry) |
| Guard scans QR | `POST /api/attendance/checkin` | `attendance` |
| Teacher adds student | `POST /api/students` | `students` |
| Enroll student in activity | `POST /api/enrollments` | `enrollments` |
| Visitor check-in | `POST /api/visitors` | `visitors` |
| Visitor check-out | `PATCH /api/visitors/:id/checkout` | `visitors.check_out_time` |

---

## 9. Seed Data Reference

The file `backend/database/seed.sql` populates the database with sample rows.

### Default users seeded by `schema.sql`

| Name | Email | Password | Role |
|------|-------|----------|------|
| System Admin | `admin@iskcon.org` | `Admin@123` | admin |

### Additional users (add manually or via `seed.sql`)
These match the Flutter app's mock credentials:

```sql
-- Guard
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES ('Gate Guard', 'guard@iskcon.org',
        '$2a$10$...', 'guard', false);

-- Teacher
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES ('Activity Teacher', 'teacher@iskcon.org',
        '$2a$10$...', 'teacher', false);

-- Principal
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES ('School Principal', 'principal@iskcon.org',
        '$2a$10$...', 'principal', false);
```

To generate a new bcrypt hash for any password:
```bash
node -e "const b=require('bcryptjs'); b.hash('YourPassword123',10).then(h=>console.log(h));"
```

---

## 10. Environment Variables Reference

Create `backend/.env` (copy from `backend/.env.example`):

| Variable | Example | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_NAME` | `iskcon_activity_db` | Database name |
| `DB_USER` | `postgres` | DB username |
| `DB_PASSWORD` | `yourpassword` | DB password |
| `JWT_SECRET` | `long-random-string` | Secret for signing JWT tokens |
| `PORT` | `5000` | Express server port |
| `CORS_ORIGIN` | `http://localhost:3000` | Allowed CORS origin |
| `NODE_ENV` | `development` | `development` or `production` |

> **Security note:** Never commit the `.env` file to git. The `.env.example` file (no real secrets) is committed as a template.
