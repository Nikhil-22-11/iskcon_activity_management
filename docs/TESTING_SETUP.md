# ISKCON Activity Management - Testing Setup Guide

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| Node.js | 18.x | Run backend server and test scripts |
| npm | 8.x | Package manager |
| PostgreSQL | 14.x | Database |
| Postman | Latest | Manual API testing with GUI |

---

## 1. Install Prerequisites

### Node.js & npm
Download and install from https://nodejs.org (LTS version recommended).

Verify:
```bash
node --version   # v18.x or higher
npm --version    # v8.x or higher
```

### PostgreSQL
Download from https://www.postgresql.org/download/

Verify:
```bash
psql --version   # psql (PostgreSQL) 14.x or higher
```

### Postman
Download from https://www.postman.com/downloads/

---

## 2. Database Setup

```bash
# Connect to PostgreSQL as superuser
psql -U postgres

# Create the database
CREATE DATABASE iskcon_activity_db;
\q

# Run the schema (creates all tables + default admin user)
psql -U postgres -d iskcon_activity_db -f backend/database/schema.sql

# Verify schema is correct
psql -U postgres -d iskcon_activity_db -f database/verifySchema.sql
```

---

## 3. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Copy environment template
cp .env.example .env

# Open .env and fill in your values:
#   DB_HOST=localhost
#   DB_PORT=5432
#   DB_NAME=iskcon_activity_db
#   DB_USER=postgres
#   DB_PASSWORD=<your_postgres_password>
#   JWT_SECRET=<any_long_random_string>
#   PORT=5000

# Install dependencies
npm install

# Start the server
npm start
```

You should see:
```
Server running on port 5000 in development mode
Health check: http://localhost:5000/health
```

Open http://localhost:5000/health in your browser to confirm the server is running.

---

## 4. Import Postman Collection

1. Open **Postman**
2. Click **Import** (top-left)
3. Select file: `postman/ISKCON_Activity_Management_API.postman_collection.json`
4. Click **Import**

### Import Environment File
1. Click **Environments** (left sidebar)
2. Click **Import**
3. Select file: `postman/environment.postman_environment.json`
4. Click **Import**
5. Click the environment name and set it as **Active**

---

## 5. Running Tests in Postman

### Step-by-step order:

1. **Authentication → Login - Admin**  
   This sets the `{{token}}` variable automatically via the test script.

2. **Student Management → Create Student**  
   Sets `{{studentId}}` variable.

3. **Activity Management → Create Activity**  
   Sets `{{activityId}}` variable.

4. Run remaining requests in any order.

### Run Full Collection at Once:
1. Right-click the collection → **Run collection**
2. Select environment: **ISKCON Activity Management - Local**
3. Click **Run ISKCON Activity Management API**
4. View results in the runner window

---

## 6. Running the Automated Test Script

```bash
# From the project root directory (not backend/)
# Make sure the server is running first!

node tests/testAPI.js
```

Expected output:
```
╔══════════════════════════════════════════════════════════╗
║   ISKCON Activity Management - API Test Suite            ║
╚══════════════════════════════════════════════════════════╝

Base URL : http://localhost:5000/api
...

📦 1. Database Connection
──────────────────────────────────────────────────
  ✅  PostgreSQL connection established
  ✅  Table 'users' exists
  ...

🎉 All tests passed!
```

---

## 7. Verifying the Database Schema

```bash
psql -U postgres -d iskcon_activity_db -f database/verifySchema.sql
```

This script checks:
- All 7 required tables exist
- All critical columns are present
- Foreign key constraints are in place
- Performance indexes exist
- The default admin user `admin@iskcon.org` exists

---

## 8. Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@iskcon.org | Admin123 |

> **Important:** The `backend/database/schema.sql` seeds the admin user with a bcrypt hash.
> Ensure the hash stored in the database corresponds to the password **`Admin123`** before running tests.
> See `backend/TESTING_GUIDE.md` → Section 7 for instructions on updating the password hash.

---

## 9. Troubleshooting

### "Connection refused" on port 5000
- Ensure the backend server is running: `cd backend && npm start`
- Check that no firewall is blocking port 5000

### Database connection error
- Verify PostgreSQL is running: `pg_isready`
- Check `.env` values (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`)
- Ensure the database `iskcon_activity_db` exists

### 401 Unauthorized in Postman
- Run **Login - Admin** first to get a fresh token
- Ensure the **environment** is set to "ISKCON Activity Management - Local"

### 403 Forbidden
- The logged-in user does not have the required role for that endpoint
- Use the admin account for full access

### `npm install` fails
- Ensure Node.js ≥ 18 is installed
- Try deleting `node_modules/` and `package-lock.json`, then run `npm install` again

### Port 5000 already in use
```bash
# macOS/Linux
lsof -i :5000
kill <PID>

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## 10. Project File Structure

```
iskcon_activity_management/
├── backend/
│   ├── .env.example          # Environment variable template
│   ├── API_DOCUMENTATION.md  # Full API reference
│   ├── TESTING_GUIDE.md      # Backend testing guide
│   ├── server.js             # Express server entry point
│   ├── config/db.js          # PostgreSQL connection
│   ├── controllers/          # Route handler logic
│   ├── middleware/           # Auth, error handling, validation
│   ├── routes/               # API route definitions
│   ├── utils/                # JWT, QR, validators, responses
│   └── database/schema.sql   # Database schema
│
├── postman/
│   ├── ISKCON_Activity_Management_API.postman_collection.json
│   ├── environment.postman_environment.json
│   └── test_results.md
│
├── tests/
│   ├── testAPI.js            # Automated Node.js test script
│   └── summary_report.md     # Test results summary
│
├── database/
│   └── verifySchema.sql      # Database verification script
│
└── docs/
    └── TESTING_SETUP.md      # This file
```
