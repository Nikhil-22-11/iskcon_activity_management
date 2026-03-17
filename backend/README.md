# ISKCON Activity Management - Backend API

Node.js/Express REST API with PostgreSQL for ISKCON School Activity Management System.

## Quick Start

```bash
cd backend
cp .env.example .env
# Edit .env with your PostgreSQL credentials
npm install
npm run dev
```

## Setup Database

```bash
psql -U postgres -c "CREATE DATABASE iskcon_activity_db;"
psql -U postgres -d iskcon_activity_db -f database/schema.sql
```

## Default Admin Login

- **Email:** admin@iskcon.org
- **Password:** Admin@123

> Change password immediately after first login.

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| **Auth** | | | |
| POST | /api/auth/login | Login | No |
| POST | /api/auth/register | Register user | Admin |
| POST | /api/auth/change-password | Change password | Yes |
| POST | /api/auth/logout | Logout | Yes |
| GET | /api/auth/me | Get current user | Yes |
| **Students** | | | |
| GET | /api/students | Get all students | Yes |
| GET | /api/students/:id | Get student | Yes |
| POST | /api/students | Create student | Teacher+ |
| PUT | /api/students/:id | Update student | Teacher+ |
| DELETE | /api/students/:id | Delete student | Admin |
| GET | /api/students/qr/:studentId | Get QR code | Yes |
| POST | /api/students/enrollment | Enroll student | Teacher+ |
| **Activities** | | | |
| GET | /api/activities | Get all activities | Yes |
| GET | /api/activities/:id | Get activity | Yes |
| POST | /api/activities | Create activity | Teacher+ |
| PUT | /api/activities/:id | Update activity | Teacher+ |
| DELETE | /api/activities/:id | Delete activity | Admin |
| GET | /api/activities/:id/students | Get enrolled students | Yes |
| **Attendance** | | | |
| POST | /api/attendance/checkin | Mark attendance (QR) | Yes |
| GET | /api/attendance/history/:studentId | Student history | Yes |
| GET | /api/attendance/date/:date | By date (YYYY-MM-DD) | Yes |
| GET | /api/attendance/report | Generate report | Admin |
| GET | /api/attendance/activity/:activityId | By activity | Yes |
| **Enquiries** | | | |
| GET | /api/enquiries | Get all enquiries | Teacher+ |
| POST | /api/enquiries | Submit enquiry | No |
| GET | /api/enquiries/:id | Get enquiry | Teacher+ |
| PUT | /api/enquiries/:id | Update enquiry | Teacher+ |
| **Visitors** | | | |
| POST | /api/visitors/checkin | Check-in visitor | Yes |
| PUT | /api/visitors/:id/checkout | Check-out visitor | Yes |
| GET | /api/visitors | Get all visitors | Yes |
| GET | /api/visitors/date/:date | By date | Yes |
| **Dashboard** | | | |
| GET | /api/dashboard/teacher | Teacher stats | Teacher+ |
| GET | /api/dashboard/principal | Principal stats | Principal+ |
| GET | /api/dashboard/stats | Overall stats | Yes |

## Roles

- `admin` - Full access
- `principal` - Admin-level access, no user registration
- `teacher` - Manage students, activities, attendance
- `guard` - Visitor check-in/out only

## Response Format

**Success:**
```json
{ "success": true, "message": "...", "data": {}, "statusCode": 200 }
```

**Error:**
```json
{ "success": false, "message": "...", "statusCode": 400 }
```

## Environment Variables

See `.env.example` for all required variables.
