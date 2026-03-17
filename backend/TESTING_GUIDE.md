# ISKCON Activity Management - Backend Testing Guide

## Overview

This guide explains how to run tests for the ISKCON Activity Management backend API.

---

## Prerequisites

| Tool | Minimum Version | Install |
|------|-----------------|---------|
| Node.js | 18.x | https://nodejs.org |
| npm | 8.x | Included with Node.js |
| PostgreSQL | 14.x | https://www.postgresql.org |
| Postman | Latest | https://www.postman.com |

---

## 1. Database Setup

```bash
# Create database
psql -U postgres -c "CREATE DATABASE iskcon_activity_db;"

# Run schema
psql -U postgres -d iskcon_activity_db -f backend/database/schema.sql

# Verify schema
psql -U postgres -d iskcon_activity_db -f database/verifySchema.sql
```

---

## 2. Backend Setup

```bash
cd backend
cp .env.example .env
# Edit .env with your DB credentials and JWT secret
npm install
npm start
```

The server starts at **http://localhost:5000**.

Health check: `GET http://localhost:5000/health`

---

## 3. Run the Automated Test Script

```bash
# From project root (requires backend server + DB running)
cd backend && npm install
node ../tests/testAPI.js
```

**Environment variable overrides:**

```bash
API_BASE_URL=http://localhost:5000/api \
DB_HOST=localhost \
DB_PORT=5432 \
DB_NAME=iskcon_activity_db \
DB_USER=postgres \
DB_PASSWORD=yourpassword \
node tests/testAPI.js
```

---

## 4. Postman Testing

### Import Collection
1. Open Postman
2. Click **Import** → select `postman/ISKCON_Activity_Management_API.postman_collection.json`

### Import Environment
1. Click **Environments** → **Import**
2. Select `postman/environment.postman_environment.json`
3. Set your **Active Environment** to "ISKCON Activity Management - Local"

### Test Order
Run requests in this order so that the `token` variable is set before protected endpoints:

1. **Authentication → Login - Admin** (sets `{{token}}`)
2. **Student Management → Create Student** (sets `{{studentId}}`)
3. **Activity Management → Create Activity** (sets `{{activityId}}`)
4. All remaining requests

### Run the Full Collection
Use Postman's **Collection Runner**:
1. Click the collection name → **Run collection**
2. Choose environment: "ISKCON Activity Management - Local"
3. Click **Run**

---

## 5. Manual cURL Tests

```bash
# Login
curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@iskcon.org","password":"Admin123"}' | jq .

# Set TOKEN variable
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@iskcon.org","password":"Admin123"}' | jq -r '.data.token')

# List students
curl -s http://localhost:5000/api/students \
  -H "Authorization: Bearer $TOKEN" | jq .

# Create student
curl -s -X POST http://localhost:5000/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Test Student","phone":"9876543210","parentName":"Test Parent"}' | jq .
```

---

## 6. Troubleshooting

### Server not starting

- Ensure PostgreSQL is running: `pg_isready -h localhost -p 5432`
- Check `.env` credentials
- Run `npm install` in the `backend/` directory

### 401 Unauthorized errors

- Re-run the **Login** request to get a fresh token
- Ensure the token is set in your environment/header

### 403 Forbidden errors

- The default admin user has the `admin` role and can access all endpoints
- If using a different user, check their `role` in the `users` table

### Database connection errors

```bash
# Test connection manually
psql -U postgres -d iskcon_activity_db -c "SELECT 1;"
```

### Port already in use

```bash
# Find process using port 5000
lsof -i :5000
# Kill it
kill <PID>
```

---

## 7. Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@iskcon.org | Admin123 |

> **Important:** The `backend/database/schema.sql` seeds the admin user with a bcrypt hash.
> The test suite and Postman collection expect the password to be **`Admin123`**.
> If the schema was inserted with a different password hash, update it before running tests:
>
> ```sql
> -- Generate a fresh bcrypt hash for 'Admin123' and update the admin user:
> UPDATE users
> SET password_hash = '$2b$10$<your_bcrypt_hash_here>'
> WHERE email = 'admin@iskcon.org';
> ```
>
> You can generate the hash in Node.js:
> ```js
> const bcrypt = require('bcrypt');
> bcrypt.hash('Admin123', 10).then(console.log);
> ```
> Then paste the output into the UPDATE statement above.
