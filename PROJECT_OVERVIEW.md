# ISKCON Activity Management System — Project Overview

> **Review-session reference document.**  
> Use this file to explain the project, walk through each feature, and answer any question about what has been built so far.

---

## Table of Contents

1. [What Is This App?](#1-what-is-this-app)
2. [Tech Stack at a Glance](#2-tech-stack-at-a-glance)
3. [Repository Structure](#3-repository-structure)
4. [Three Roles & Login Credentials](#4-three-roles--login-credentials)
5. [Role Dashboards](#5-role-dashboards)
   - [Guard Dashboard](#51-guard-dashboard)
   - [Teacher Dashboard](#52-teacher-dashboard)
   - [Principal Dashboard](#53-principal-dashboard)
6. [Activities List](#6-activities-list)
7. [Admission Form](#7-admission-form)
8. [QR Code JSON Payloads](#8-qr-code-json-payloads)
9. [Mock API Layer Explained](#9-mock-api-layer-explained)
10. [Navigation Structure](#10-navigation-structure)
11. [How to Run — Windows Desktop](#11-how-to-run--windows-desktop)
12. [How to Run — Android Emulator](#12-how-to-run--android-emulator)
13. [Review-Session Talking Points](#13-review-session-talking-points)
14. [Build Checklist](#14-build-checklist)

---

## 1. What Is This App?

**ISKCON Activity Management System** is a Flutter mobile/desktop application designed for an ISKCON school to manage:

- After-school activities (swimming, yoga, Sanskrit, arts, etc.)
- Student enrollment and attendance tracking
- Visitor check-in via QR scanning (Guard role)
- Student admission forms
- Reporting and financial tracking (Principal role)

The project consists of two independent layers:

| Layer | Technology | Location |
|-------|-----------|----------|
| **Flutter Front-end** | Flutter 3 / Dart 3 | `flutter_app/` |
| **REST Back-end** | Node.js / Express / PostgreSQL | `backend/` |

The Flutter app **works entirely offline using built-in mock data**; it optionally calls the real backend when available.

---

## 2. Tech Stack at a Glance

### Flutter App
| Item | Detail |
|------|--------|
| Language | Dart 3 |
| Framework | Flutter 3 |
| State | `setState` + service singletons |
| HTTP Client | `http` package (`ApiService`) |
| Mock Data | `MockDataService` (singleton, in-memory) |
| QR Generation | `qr_flutter` package |
| Theme | Material 3, ISKCON blue (`#1565C0`) + saffron orange (`#FF6F00`) |

### Backend
| Item | Detail |
|------|--------|
| Language | Node.js 18+ |
| Framework | Express 4 |
| Database | PostgreSQL 14+ |
| Auth | JWT (`jsonwebtoken`) + bcrypt |
| Rate Limiting | `express-rate-limit` |
| Port | `5000` |

---

## 3. Repository Structure

```
iskcon_activity_management/
├── README.md                        # One-line project description
├── PROJECT_OVERVIEW.md              # ← this file
├── DATABASE_GUIDE.md                # Data inspection guide
├── backend/                         # Node.js/Express REST API
│   ├── server.js                    # App entry point (port 5000)
│   ├── setup-db.js                  # DB initialisation helper
│   ├── config/db.js                 # PostgreSQL connection pool
│   ├── controllers/                 # Business logic per resource
│   ├── routes/                      # Express router files
│   ├── middleware/                  # Auth, validation, error handling
│   ├── utils/                       # JWT, QR generator, responses
│   ├── database/
│   │   ├── schema.sql               # Full table definitions
│   │   ├── seed.sql                 # Sample rows
│   │   └── init.sql                 # UUID extension + tables
│   ├── API_DOCUMENTATION.md         # Full REST API reference
│   └── TESTING_GUIDE.md
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart                # MaterialApp entry point
│   │   ├── models/                  # Dart data classes
│   │   ├── screens/                 # Every UI screen
│   │   ├── services/
│   │   │   ├── api_service.dart     # HTTP client + mock fallback
│   │   │   ├── mock_data_service.dart # In-memory mock data
│   │   │   └── qr_service.dart      # QR payload helpers
│   │   ├── navigation/routes.dart   # Named route definitions
│   │   └── utils/
│   │       ├── constants.dart       # Colors, API URLs, strings
│   │       └── theme.dart           # Material theme
│   └── pubspec.yaml
├── database/
│   └── verifySchema.sql             # Quick verification queries
├── docs/TESTING_SETUP.md
├── postman/                         # Postman collection + results
└── tests/testAPI.js                 # Automated API test script
```

---

## 4. Three Roles & Login Credentials

The app recognises four roles but the main review covers three:

| Role | Email | Password | What they can do |
|------|-------|----------|-----------------|
| **Guard** | `guard@iskcon.org` | `Guard123` | Scan QR codes, view scan history |
| **Teacher** | `teacher@iskcon.org` | `Teacher123` | View students/activities, mark attendance, submit admissions |
| **Principal** | `principal@iskcon.org` | `Principal123` | Full overview, students, attendance trends, activities, finance |
| Admin | `admin@iskcon.org` | `Admin123` | System-wide (backend only) |

> **How login works:** The mock credentials are matched in `ApiService.login()` before any network call. The app generates an in-memory JWT-like token, stores it in memory, and routes to the correct dashboard. If the real backend is running, it also calls `POST /api/auth/login` in the background.

---

## 5. Role Dashboards

### 5.1 Guard Dashboard

**Screen file:** `lib/screens/guard_dashboard.dart`

**What you see:**
- ISKCON saffron/blue themed header with user name
- **"Scan QR" button** — simulates a QR scan (2-second animation, then displays result)
- **Scan history list** — shows the last 6 mock scans with student name, activity, and timestamp

**How the QR scan works (mock mode):**
1. User taps "Scan QR"
2. App cycles through 6 pre-loaded mock QR payloads (see §8)
3. Displays the decoded student + activity information
4. Adds the record to the in-memory scan history

**Backend endpoint used (when connected):**
- `POST /api/attendance/checkin` — body: `{ qr_data, activity_id?, notes? }`
- `GET /api/attendance/scan-history` (mock: returns `MockDataService().getQrScanHistory()`)

---

### 5.2 Teacher Dashboard

**Screen file:** `lib/screens/teacher_dashboard.dart`

**What you see:**
- Stats row: Total Students | Present Today | Absent Today
- **"Upcoming Activities" button** → opens `ActivityListScreen` with enrolled student counts
- **"Admission" button** → opens the Admission Form (§7)
- Attendance history table

**Backend endpoint:** `GET /api/dashboard/teacher`  
**Mock fallback:** Returns calculated stats from `MockDataService`

---

### 5.3 Principal Dashboard

**Screen file:** `lib/screens/principal_dashboard.dart`

Five tabs across the bottom navigation bar:

| Tab # | Tab Name | Content |
|-------|----------|---------|
| 1 | **Overview** | Stats cards: total students, activities, teachers, avg attendance %; quick-action buttons |
| 2 | **Students** | Searchable list of 22+ students with roll number, DOB, enrolled activity count |
| 3 | **Attendance** | Monthly bar chart with percentage attendance per month |
| 4 | **Activities** | All 10 activities with enrolled/capacity ratio and enroll button |
| 5 | **Finance** | Revenue summary, payment modes (Cash vs Online), pending payments list |

**Backend endpoint:** `GET /api/dashboard/principal`  
**Mock fallback:** Returns structured mock stats with `monthlyStats`, `activityStats`, `financial`, and `students` arrays.

---

## 6. Activities List

Ten activities are available in the system (defined in `MockDataService._activities`):

| # | Activity | Schedule | Teacher | Capacity | Age Group |
|---|----------|----------|---------|----------|-----------|
| 1 | Swimming | Mon, Wed, Fri — 7:00 AM | Coach Mahesh | 20 | 8+ |
| 2 | Yoga | Daily — 6:00 AM | Prabhu Gopal Das | 30 | All ages |
| 3 | Self-Defence | Tue, Thu — 4:00 PM | Instructor Ravi | 25 | 10+ |
| 4 | Phonix | Mon, Wed — 10:00 AM | Mataji Tulsi Devi | 20 | 5–10 |
| 5 | Art & Craft | Saturday — 10:00 AM | Mataji Saraswati Devi | 25 | All ages |
| 6 | Sanskrit | Mon, Thu — 4:00 PM | Prabhu Nityananda Das | 25 | 12–18 |
| 7 | Speech & Drama | Sunday — 3:00 PM | Mataji Bhakti Devi | 30 | 8–18 |
| 8 | Indian Culture and Values | Fri — 3:00 PM | HH Radhanath Swami | 40 | 5–15 |
| 9 | Bharat Natyam | Tue, Sat — 5:00 PM | Mataji Radha Devi | 20 | 6–16 |
| 10 | Music & Movement | Wed, Fri — 4:30 PM | Prabhu Hari Das | 30 | 4–12 |

Current mock enrollment counts: Swimming 6, Yoga 7, Self-Defence 5, Phonix 4, Art & Craft 8, Sanskrit 5, Speech & Drama 6, Indian Culture 8, Bharat Natyam 5, Music & Movement 8.

---

## 7. Admission Form

**Screen file:** `lib/screens/admission_form.dart`

The admission form collects new-student information and is accessible from the Teacher Dashboard.

### Form Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Student Name | Text input | ✅ | Full name |
| Date of Birth | Date picker | ✅ | Opens calendar |
| Mother's Contact | Phone input | ✅ | |
| Father's Contact | Phone input | ✅ | |
| School | Text input | ✅ | Current school name |
| Gender | Dropdown | ✅ | Male / Female / Other |
| How did you hear about us? | Dropdown | — | Friends / Social Media / Posters / Events |
| Payment Period | Dropdown | ✅ | Monthly / Quarterly / Yearly |
| Payment Mode | Dropdown | ✅ | Cash / Online |
| Transaction ID | Text input | Conditional | Shown only when Payment Mode = Online |

### Submitted JSON payload

```json
{
  "student_name": "Arjun Sharma",
  "dob": "2010-05-15",
  "mother_contact": "9876543200",
  "father_contact": "9876543201",
  "school": "Delhi Public School",
  "gender": "Male",
  "hear_about_us": "Friends",
  "payment_period": "Monthly",
  "payment_mode": "Online",
  "transaction_id": "TXN20260318001"
}
```

**Submission:** `POST /api/admissions` (mock fallback: `MockDataService().addAdmission(data)`)

---

## 8. QR Code JSON Payloads

QR payloads are defined in `lib/services/qr_service.dart` and are scanned by the Guard.

### Attendance Check-in QR (primary payload)
```json
{
  "studentId": 1,
  "studentName": "Arjun Sharma",
  "activityId": 1,
  "activityName": "Swimming",
  "timestamp": "2026-03-18T07:39:51Z"
}
```

### Student Identity QR
```json
{
  "type": "student",
  "id": 1,
  "name": "Arjun Sharma",
  "phone": "9876543210"
}
```

### Activity QR
```json
{
  "type": "activity",
  "id": 1,
  "name": "Swimming",
  "schedule": "Mon, Wed, Fri - 7:00 AM"
}
```

### Visitor QR
```json
{
  "type": "visitor",
  "id": 1,
  "name": "Ramesh Gupta",
  "phone": "9123456789",
  "checkInTime": "2026-03-18T10:00:00Z"
}
```

---

## 9. Mock API Layer Explained

The Flutter app uses a **hybrid data strategy**: it always tries the live backend first; if the call fails (network error, server not running, etc.) it silently falls back to mock data.

```
User action
    │
    ▼
ApiService.someMethod()
    │
    ├── _isMockToken()?  ──YES──► MockDataService.getData()  ◄── always works offline
    │
    └── NO ─► HTTP request to http://127.0.0.1:5000/api/...
                   │
                   ├── 200 OK  ──► return real data
                   └── error   ──► MockDataService.getData()  ◄── graceful fallback
```

**Mock credentials** are matched inside `ApiService.login()` before any network call:

| Email | Mock token returned |
|-------|-------------------|
| `guard@iskcon.org` | `mock-guard-token` |
| `teacher@iskcon.org` | `mock-teacher-token` |
| `principal@iskcon.org` | `mock-principal-token` |

If none of these match, a real `POST /api/auth/login` is attempted.

**MockDataService** (`lib/services/mock_data_service.dart`) holds:
- 22 students with full contact details
- 10 activities with schedules and teacher names
- 7 sample attendance records
- 3 sample visitors
- 6 rotatable QR scan history entries
- Enrollment map (which students are in which activities)
- In-memory admission submissions list

---

## 10. Navigation Structure

```
LoginScreen  (route: '/')
      │
      ├─[guard]──────► GuardDashboard      ('/guard-dashboard')
      │                       └─ QR scan history
      │
      ├─[teacher]────► TeacherDashboard    ('/teacher-dashboard')
      │                       ├─ ActivityListScreen  ('/activities')
      │                       ├─ AdmissionForm       (modal/push)
      │                       ├─ StudentListScreen   ('/students')
      │                       └─ AttendanceScreen    ('/attendance')
      │
      └─[principal]──► PrincipalDashboard  ('/principal-dashboard')
                              ├─ Tab 1: Overview
                              ├─ Tab 2: Students
                              ├─ Tab 3: Attendance
                              ├─ Tab 4: Activities
                              └─ Tab 5: Finance
```

Routes are defined in `lib/navigation/routes.dart` as `AppRoutes` constants.  
`MaterialApp` is configured with `initialRoute: AppRoutes.login` and `onGenerateRoute: AppRoutes.generateRoute`.

---

## 11. How to Run — Windows Desktop

> **Prerequisites:** Flutter SDK 3.x installed; Windows Build Tools enabled in `flutter doctor`.

```powershell
# 1. Navigate to the Flutter app
cd C:\path\to\iskcon_activity_management\flutter_app

# 2. Get dependencies
flutter pub get

# 3. Run on Windows
flutter run -d windows
```

The app launches as a native Windows window.  
Test with:  
- **Guard:** `guard@iskcon.org` / `Guard123`  
- **Teacher:** `teacher@iskcon.org` / `Teacher123`  
- **Principal:** `principal@iskcon.org` / `Principal123`

---

## 12. How to Run — Android Emulator

### Step 1 — Create an emulator in Android Studio
1. Open **Android Studio** → **More Actions** → **Virtual Device Manager**
2. Click **Create device** → choose **Pixel 5** (or any phone)
3. Choose a system image (Android 13 or 14, x86_64)
4. Click **Finish**, then press **▶ Play** to start the emulator

### Step 2 — Verify Flutter sees the emulator
```bash
flutter emulators          # lists all configured emulators
flutter devices            # shows running devices
```

You should see something like:
```
emulator-5554 • Android SDK Built for x86_64 • android-x64
```

### Step 3 — Run the app
```bash
cd flutter_app
flutter run -d emulator-5554
```

Or simply `flutter run` if it is the only running device.

### Step 4 — First build
The first Android build can take **5–10 minutes**. Subsequent builds are faster due to Gradle caching.

### Troubleshooting
| Symptom | Fix |
|---------|-----|
| `flutter devices` shows nothing | Check that the emulator is fully booted (home screen visible) |
| `adb devices` shows `unauthorized` | Accept the debugging prompt on the emulator screen |
| Build fails with Kotlin/Gradle error | Run `flutter clean && flutter pub get`, then try again |
| App opens on Windows instead of emulator | Use `-d emulator-5554` explicitly |

---

## 13. Review-Session Talking Points

Use these points to present the project confidently:

### What problem are we solving?
> "ISKCON runs multiple after-school activities for children. Previously, attendance and visitor management were done on paper. This app digitises everything: QR-based check-in for students, a portal for teachers to view their classes, and a full analytics dashboard for the principal."

### Architecture decision — why mock data?
> "The app is designed to work with or without a live server. The `MockDataService` means a reviewer or demo audience can see the complete product without setting up a PostgreSQL database. When the backend is deployed, the app automatically uses real data."

### Three roles — what makes each unique?
- **Guard** — security-first view; only see QR scan history; no access to student details or finance.
- **Teacher** — operational view; manage their students, record attendance, submit new admissions.
- **Principal** — management view; financial summary, monthly attendance trends, activity capacity tracking.

### Finance Tab (Principal)
> "The Finance tab shows total admission revenue broken down by payment period (Monthly/Quarterly/Yearly) and payment mode (Cash/Online). It also lists students with pending payment so the administration team can follow up."

### QR Check-in flow
> "When a student arrives, the guard taps 'Scan QR'. The app decodes a JSON payload containing the student ID, name, activity ID, and timestamp. That payload is sent to the backend attendance endpoint which records the check-in. In mock mode the scan cycles through 6 pre-loaded payloads to demonstrate the flow."

---

## 14. Build Checklist

### ✅ Completed
- [x] Flutter project structure with `models/`, `screens/`, `services/`, `navigation/`, `utils/`
- [x] Login screen with role-based routing
- [x] Guard Dashboard — QR scanner simulation, scan history
- [x] Teacher Dashboard — student stats, upcoming activities, attendance history, admission form button
- [x] Principal Dashboard — all 5 tabs (Overview, Students, Attendance, Activities, Finance)
- [x] Admission Form — all fields, conditional transaction ID, mock submission
- [x] 22 mock students with full contact details
- [x] 10 activities with schedules, teachers, capacity
- [x] QR payload helpers (attendance, student, activity, visitor types)
- [x] Mock API layer with graceful fallback
- [x] Node.js/Express backend with JWT authentication
- [x] PostgreSQL schema (7 tables: users, students, activities, enrollments, attendance, enquiries, visitors)
- [x] Seed data and schema verification script
- [x] Postman collection + automated API test script
- [x] API documentation (`backend/API_DOCUMENTATION.md`)
- [x] ISKCON blue + saffron orange Material theme

### ⬜ Future / Optional Enhancements
- [ ] Connect Flutter app to live backend in production environment
- [ ] Real QR code scanning via device camera (`mobile_scanner` package)
- [ ] Push notifications for activity reminders
- [ ] Export attendance/finance reports as PDF
- [ ] Photo capture for visitor check-in
- [ ] Admin user-management screen (create/deactivate staff accounts)
