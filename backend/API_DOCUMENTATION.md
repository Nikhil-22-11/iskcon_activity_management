# ISKCON Activity Management - API Documentation

**Version:** 1.0.0  
**Base URL:** `http://localhost:5000/api`  
**Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Students](#students)
3. [Activities](#activities)
4. [Attendance](#attendance)
5. [Visitors](#visitors)
6. [Enquiries](#enquiries)
7. [Dashboard](#dashboard)
8. [Response Format](#response-format)
9. [Error Codes](#error-codes)
10. [Authentication Setup](#authentication-setup)
11. [Rate Limiting](#rate-limiting)
12. [CORS Configuration](#cors-configuration)

---

## Authentication

All protected endpoints require a **Bearer token** in the `Authorization` header:

```
Authorization: Bearer <JWT_TOKEN>
```

### POST `/auth/login`

Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "email": "admin@iskcon.org",
  "password": "Admin123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGci...",
    "user": {
      "id": 1,
      "name": "System Admin",
      "email": "admin@iskcon.org",
      "role": "admin"
    }
  },
  "statusCode": 200
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password",
  "statusCode": 401
}
```

---

### POST `/auth/register`

Register a new user. Requires `admin` or `principal` role.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Mohan Das",
  "email": "mohan@iskcon.org",
  "password": "Password123",
  "role": "teacher"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 2,
    "name": "Mohan Das",
    "email": "mohan@iskcon.org",
    "role": "teacher"
  },
  "statusCode": 201
}
```

---

### POST `/auth/change-password`

Change the authenticated user's password.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "currentPassword": "Admin123",
  "newPassword": "NewPassword456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully",
  "statusCode": 200
}
```

---

### GET `/auth/me`

Get the currently authenticated user's profile.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "System Admin",
    "email": "admin@iskcon.org",
    "role": "admin",
    "is_active": true
  },
  "statusCode": 200
}
```

---

### POST `/auth/logout`

Logout the current user (invalidates token server-side if applicable).

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "statusCode": 200
}
```

---

## Students

All student endpoints require authentication.

### GET `/students`

Get a paginated list of all students.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 10 | Results per page |
| `search` | string | — | Search by name or student_id |

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "student_id": "STU001",
      "name": "Arjun Kumar",
      "email": "arjun@example.com",
      "phone": "9876543210",
      "parent_name": "Rajesh Kumar",
      "is_active": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "pages": 1
  },
  "statusCode": 200
}
```

---

### POST `/students`

Create a new student. Requires `admin`, `principal`, or `teacher` role.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Arjun Kumar",
  "email": "arjun@example.com",
  "phone": "9876543210",
  "dateOfBirth": "2015-05-20",
  "parentName": "Rajesh Kumar",
  "parentPhone": "9876543211",
  "address": "123 Krishna Lane",
  "activities": [1, 2]
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Student created successfully",
  "data": {
    "id": 1,
    "student_id": "STU001",
    "name": "Arjun Kumar",
    "qr_code": "data:image/png;base64,..."
  },
  "statusCode": 201
}
```

---

### GET `/students/:id`

Get a single student by their database ID.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "student_id": "STU001",
    "name": "Arjun Kumar",
    "email": "arjun@example.com",
    "phone": "9876543210",
    "parent_name": "Rajesh Kumar",
    "parent_phone": "9876543211",
    "address": "123 Krishna Lane",
    "date_of_birth": "2015-05-20",
    "activities": []
  },
  "statusCode": 200
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Student not found",
  "statusCode": 404
}
```

---

### PUT `/students/:id`

Update a student's information. Requires `admin`, `principal`, or `teacher` role.

**Headers:** `Authorization: Bearer <token>`

**Request Body (all fields optional):**
```json
{
  "name": "Arjun Kumar Updated",
  "phone": "9876543210",
  "address": "456 New Krishna Lane"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Student updated successfully",
  "data": { "id": 1, "name": "Arjun Kumar Updated" },
  "statusCode": 200
}
```

---

### DELETE `/students/:id`

Delete a student (soft-delete). Requires `admin` or `principal` role.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Student deleted successfully",
  "statusCode": 200
}
```

---

### GET `/students/qr/:studentId`

Get the QR code for a student.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "studentId": 1,
    "student_id": "STU001",
    "name": "Arjun Kumar",
    "qrCode": "data:image/png;base64,..."
  },
  "statusCode": 200
}
```

---

## Activities

All activity endpoints require authentication.

### GET `/activities`

Get all activities (paginated).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:** `page`, `limit`

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Bhagavad Gita Class",
      "description": "Learn Bhagavad Gita teachings",
      "schedule": "Mon, Wed, Fri - 6:00 PM",
      "is_active": true
    }
  ],
  "pagination": { "page": 1, "limit": 10, "total": 1, "pages": 1 },
  "statusCode": 200
}
```

---

### POST `/activities`

Create a new activity. Requires `admin`, `principal`, or `teacher` role.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Bhagavad Gita Class",
  "description": "Learn Bhagavad Gita teachings",
  "schedule": "Mon, Wed, Fri - 6:00 PM",
  "capacity": 50,
  "teacher": "Swami Ji",
  "ageGroup": "8-15"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Activity created successfully",
  "data": { "id": 1, "name": "Bhagavad Gita Class" },
  "statusCode": 201
}
```

---

### GET `/activities/:id`

Get activity details.

**Headers:** `Authorization: Bearer <token>`

---

### PUT `/activities/:id`

Update an activity. Requires `admin`, `principal`, or `teacher` role.

**Headers:** `Authorization: Bearer <token>`

---

### DELETE `/activities/:id`

Delete an activity. Requires `admin` or `principal` role.

**Headers:** `Authorization: Bearer <token>`

---

### GET `/activities/:id/students`

Get all students enrolled in an activity.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Arjun Kumar", "student_id": "STU001" }
  ],
  "pagination": { "page": 1, "limit": 10, "total": 1, "pages": 1 },
  "statusCode": 200
}
```

---

## Attendance

All attendance endpoints require authentication.

### POST `/attendance/checkin`

Mark student attendance (check-in).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "studentId": 1,
  "activityId": 1,
  "checkInTime": "2026-03-17T06:00:00Z"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Attendance marked successfully",
  "data": {
    "id": 1,
    "student_id": 1,
    "activity_id": 1,
    "check_in_time": "2026-03-17T06:00:00.000Z",
    "status": "present"
  },
  "statusCode": 201
}
```

---

### GET `/attendance/history/:studentId`

Get attendance history for a specific student.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:** `page`, `limit`

---

### GET `/attendance/date/:date`

Get all attendance records for a specific date (format: `YYYY-MM-DD`).

**Headers:** `Authorization: Bearer <token>`

---

### GET `/attendance/report`

Generate overall attendance report. Requires `admin` or `principal` role.

**Headers:** `Authorization: Bearer <token>`

---

### GET `/attendance/activity/:activityId`

Get attendance records for a specific activity.

**Headers:** `Authorization: Bearer <token>`

---

## Visitors

All visitor endpoints require authentication.

### POST `/visitors/checkin`

Check-in a visitor.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "visitorName": "Sharma Ji",
  "visitorPhone": "9876543212",
  "visitReason": "Student pickup",
  "studentName": "Arjun Kumar"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Visitor checked in successfully",
  "data": {
    "id": 1,
    "name": "Sharma Ji",
    "check_in_time": "2026-03-17T12:00:00.000Z",
    "status": "checked_in"
  },
  "statusCode": 201
}
```

---

### PUT `/visitors/:id/checkout`

Check-out a visitor.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Visitor checked out successfully",
  "data": {
    "id": 1,
    "check_out_time": "2026-03-17T13:00:00.000Z",
    "status": "checked_out"
  },
  "statusCode": 200
}
```

---

### GET `/visitors`

Get all visitors (paginated).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:** `page`, `limit`

---

### GET `/visitors/date/:date`

Get visitors for a specific date (format: `YYYY-MM-DD`).

**Headers:** `Authorization: Bearer <token>`

---

## Enquiries

The `POST /enquiries` endpoint is public. All other endpoints require authentication with `admin`, `principal`, or `teacher` role.

### POST `/enquiries`

Submit a new enquiry (public, no authentication required).

**Request Body:**
```json
{
  "name": "Priya Singh",
  "email": "priya@example.com",
  "phone": "9876543213",
  "interestedActivities": "Yoga, Meditation",
  "message": "Interested in joining"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Enquiry submitted successfully",
  "data": { "id": 1, "name": "Priya Singh", "status": "new" },
  "statusCode": 201
}
```

---

### GET `/enquiries`

Get all enquiries (paginated). Requires auth.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:** `page`, `limit`

---

### GET `/enquiries/:id`

Get enquiry details. Requires auth.

**Headers:** `Authorization: Bearer <token>`

---

### PUT `/enquiries/:id`

Update enquiry status/notes. Requires auth.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "in_progress",
  "notes": "Contacted by phone"
}
```

---

## Dashboard

All dashboard endpoints require authentication.

### GET `/dashboard/teacher`

Teacher dashboard stats. Requires `admin`, `principal`, or `teacher` role.

**Headers:** `Authorization: Bearer <token>`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "totalStudents": 50,
    "todayAttendance": 42,
    "activities": 8
  },
  "statusCode": 200
}
```

---

### GET `/dashboard/principal`

Principal/admin dashboard stats. Requires `admin` or `principal` role.

**Headers:** `Authorization: Bearer <token>`

---

### GET `/dashboard/stats`

Overall system statistics. Requires authentication.

**Headers:** `Authorization: Bearer <token>`

---

## Response Format

### Success Response

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "statusCode": 200
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "error": "details",
  "statusCode": 400
}
```

---

## Error Codes

| HTTP Code | Meaning |
|-----------|---------|
| `200` | Success |
| `201` | Created |
| `400` | Bad Request (validation error or missing fields) |
| `401` | Unauthorized (missing or invalid token) |
| `403` | Forbidden (insufficient role) |
| `404` | Not Found |
| `409` | Conflict (duplicate resource) |
| `429` | Too Many Requests (rate limit exceeded) |
| `500` | Internal Server Error |

---

## Authentication Setup

1. **Login** with admin credentials:
   ```bash
   curl -X POST http://localhost:5000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"admin@iskcon.org","password":"Admin123"}'
   ```

2. **Copy** the `token` from the response.

3. **Use** it in subsequent requests:
   ```bash
   curl http://localhost:5000/api/students \
     -H "Authorization: Bearer <YOUR_TOKEN>"
   ```

Tokens expire after **7 days** by default (configurable via `JWT_EXPIRES_IN` in `.env`).

---

## Rate Limiting

| Scope | Limit | Window |
|-------|-------|--------|
| Global (all routes) | 200 requests | 15 minutes |
| Authentication routes (`/api/auth/*`) | 20 requests | 15 minutes |

When a rate limit is exceeded, the API returns:
```json
{
  "success": false,
  "message": "Too many requests. Please try again later.",
  "statusCode": 429
}
```

---

## CORS Configuration

The API allows cross-origin requests from the origin defined in the `CORS_ORIGIN` environment variable (defaults to `*` in development).

Allowed methods: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `OPTIONS`  
Allowed headers: `Content-Type`, `Authorization`

For production, set `CORS_ORIGIN=https://your-frontend-domain.com` in `.env`.
