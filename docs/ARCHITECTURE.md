# ISKCON Activity Management – Technical Architecture Deep-Dive

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Repository Layout](#2-repository-layout)
3. [Flutter App Architecture](#3-flutter-app-architecture)
4. [Role-Based Routing](#4-role-based-routing)
5. [Dashboards](#5-dashboards)
6. [QR Generation & Scanning Data Flow](#6-qr-generation--scanning-data-flow)
7. [Admission Form – Data Model & Validation](#7-admission-form--data-model--validation)
8. [Mock API / Data Layer](#8-mock-api--data-layer)
9. [Current Persistence Approach](#9-current-persistence-approach)
10. [Node.js Backend & PostgreSQL Schema](#10-nodejs-backend--postgresql-schema)
11. [Adding a Real Database (SQLite / Firebase / Backend)](#11-adding-a-real-database-sqlite--firebase--backend)
12. [Verifying Stored Records at Runtime](#12-verifying-stored-records-at-runtime)

---

## 1. Project Overview

**ISKCON Activity Management** is a Flutter application (Windows desktop + Android) that manages:
- Student activity enrolments
- Attendance marking via QR scan
- Student admissions
- Role-specific dashboards for Guard, Teacher, and Principal

The app ships with a **full mock data layer** so it runs completely offline without a backend. A separate Node.js / PostgreSQL backend exists for production use; the Flutter app automatically falls back to mock data when the backend is unavailable.

---

## 2. Repository Layout

```
iskcon_activity_management/
├── flutter_app/               # Flutter client (Windows + Android)
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── models/            # Pure Dart data classes
│   │   ├── navigation/        # Route table (routes.dart)
│   │   ├── screens/           # One file per screen / dashboard
│   │   ├── services/          # ApiService + MockDataService
│   │   └── utils/             # AppColors, AppStrings, AppUrls, AppTheme
│   └── pubspec.yaml           # Flutter dependencies
│
├── backend/                   # Node.js REST API
│   ├── server.js              # Express entry point
│   ├── config/db.js           # PostgreSQL pool (node-postgres)
│   ├── controllers/           # Business logic per domain
│   ├── routes/                # Express routers
│   ├── middleware/            # Auth, validation, error handling
│   ├── database/
│   │   ├── schema.sql         # CREATE TABLE statements
│   │   ├── seed.sql           # Sample data
│   │   └── init.sql           # Combined init script
│   └── utils/                 # JWT, QR generator, validators, responses
│
├── docs/                      # Technical documentation
├── postman/                   # Postman collection + environment
├── tests/                     # API test scripts
└── database/                  # Standalone SQL verification scripts
```

---

## 3. Flutter App Architecture

### Entry Point (`main.dart`)

```dart
void main() => runApp(const ISKCONApp());
```

`ISKCONApp` is a stateless `MaterialApp` that:
1. Applies `AppTheme.lightTheme` (ISKCON blue / orange colour palette)
2. Sets `initialRoute` to `AppRoutes.login` (`/`)
3. Delegates all navigation to `AppRoutes.generateRoute`

### Layered Design

```
UI (Screens)
    │  setState / Future<void>
    ▼
ApiService (singleton)          ← single source of truth for all data calls
    │  mock token? → MockDataService
    │  real token? → HTTP (http package) → Node.js backend
    ▼
SharedPreferences               ← session token + current user (JSON)
```

### Key Dependencies (`pubspec.yaml`)

| Package | Purpose |
|---|---|
| `http` | HTTP calls to Node.js backend |
| `shared_preferences` | Persist auth token, user JSON, admissions |
| `intl` | Date / number formatting |
| `qr_flutter` | Render QR code widget from string data |
| `cupertino_icons` | iOS-style icons |

---

## 4. Role-Based Routing

### Login Screen → Role Detection

`LoginScreen._handleLogin()` calls `ApiService().login(email, password)`.

`ApiService.login()` first checks hardcoded mock credentials:

```dart
const credentials = {
  'guard@iskcon.org':     {'password': 'Guard123',     'role': 'guard'},
  'teacher@iskcon.org':   {'password': 'Teacher123',   'role': 'teacher'},
  'principal@iskcon.org': {'password': 'Principal123', 'role': 'principal'},
};
```

If a match is found it creates a `UserModel` with the matching role and saves it to `SharedPreferences`. It then **silently** tries the real backend; if the backend returns a real JWT it replaces the mock token.

### Route Decision

Back in `LoginScreen._handleLogin()`:

```dart
if (user.isGuard)      route = AppRoutes.guardDashboard;
else if (user.isTeacher)    route = AppRoutes.teacherDashboard;
else if (user.isPrincipal)  route = AppRoutes.principalDashboard;
```

`Navigator.pushReplacementNamed(route)` triggers `AppRoutes.generateRoute` which maps each string constant to a `MaterialPageRoute`:

| Constant | Route String | Screen |
|---|---|---|
| `AppRoutes.login` | `/` | `LoginScreen` |
| `AppRoutes.guardDashboard` | `/guard-dashboard` | `GuardDashboard` |
| `AppRoutes.teacherDashboard` | `/teacher-dashboard` | `TeacherDashboard` |
| `AppRoutes.principalDashboard` | `/principal-dashboard` | `PrincipalDashboard` |
| `AppRoutes.studentList` | `/students` | `StudentListScreen` |
| `AppRoutes.activityList` | `/activities` | `ActivityListScreen` |
| `AppRoutes.attendance` | `/attendance` | `AttendanceScreen` |
| `AppRoutes.visitorCheckIn` | `/visitor-checkin` | `VisitorCheckInScreen` |
| `AppRoutes.dataInspector` | `/data-inspector` | `DataInspectorScreen` |

### Session Persistence

`SharedPreferences` stores:
- `auth_token` – JWT string (or `mock_token_iskcon_dev` in mock mode)
- `user_data` – JSON-encoded `UserModel`
- `admissions_data` – JSON-encoded list of admission records

When the app restarts, `ApiService.getCurrentUser()` reads `user_data` from prefs so the user stays logged in.

### Token-based Mock/Real Switch

`ApiService._isMockToken(token)` returns `true` if the token equals `mock_token_iskcon_dev` or starts with `mock_`. Every data method checks this flag:

```dart
if (_isMockToken(token)) {
  return MockDataService().getStudents(); // offline mock
}
// else → real HTTP call to backend
```

---

## 5. Dashboards

### 5.1 Guard Dashboard (`guard_dashboard.dart`)

**Purpose:** Attendance marking via QR code scan simulation.

**State:**
- `_scanHistory` – list of processed QR scan records
- `_isScanning` – controls the scanning overlay dialog

**Data flow:**
1. `initState` → `_loadData()` → `ApiService().getQrScanHistory()` → `MockDataService().getQrScanHistory()`  
   Returns 6 pre-seeded scans showing student name, activity, and timestamp.
2. Tap "Scan QR" → `_simulateScan()`:
   - Shows `_ScanningDialog` for 2 seconds (simulates camera)
   - Picks next payload from `_mockQrPayloads` list (rotates through 6 entries)
   - Calls `ApiService().processQrScan(payload)` → `MockDataService().addQrScan(data)`
   - Prepends result to `_scanHistory` and shows success card

**No camera plugin is used** – scanning is fully simulated in mock mode. When connected to the real backend, `processQrScan` POSTs to `POST /api/attendance/qr-checkin`.

---

### 5.2 Teacher Dashboard (`teacher_dashboard.dart`)

**Purpose:** Activity overview and student admissions.

**Tabs / Sections (scrollable):**
- Welcome banner with teacher name
- "Upcoming Activities" card (clickable → `ActivityListScreen`)
  - Shows enrolled student count per activity
- "Add New Admission" button → pushes `AdmissionForm`
- Recent attendance summary (last 7 days)

**Data flow:**
1. `_loadData()` → `ApiService().getTeacherDashboard()` → `MockDataService().getTeacherDashboard()`
2. Response includes `upcoming_activities`, `today_attendance`, `total_students`
3. Tapping an activity → `ApiService().getEnrolledStudents(activityId)` → returns students from `MockDataService._enrollments` map

---

### 5.3 Principal Dashboard (`principal_dashboard.dart`)

**Purpose:** Full management overview across 5 tabs.

**Tabs:**

| # | Tab | Content |
|---|---|---|
| 1 | Overview | Stats cards, activity chart, quick-action buttons |
| 2 | Students | Searchable list of 22 students |
| 3 | Attendance | Monthly trends, per-activity breakdown |
| 4 | Activities | All 10 activities with enrollment counts |
| 5 | Finance | Revenue summary, payment mode split, pending payments |

**App bar actions:**
- Refresh button → re-fetches dashboard data
- Data Inspector button (`storage` icon) → opens `DataInspectorScreen`
- Logout button

**Data flow:**
`ApiService().getPrincipalDashboard()` → `MockDataService().getPrincipalDashboard()` returns a comprehensive map including `total_students`, `total_activities`, `activities_overview`, `monthly_attendance`, `monthly_revenue`, `payment_modes`, `pending_payments`.

---

## 6. QR Generation & Scanning Data Flow

### Generation Side (Teacher / Principal)

`QrService` (`services/qr_service.dart`) generates JSON strings that are passed to the `qr_flutter` `QrImageView` widget:

```dart
// Attendance QR payload
String attendanceQrData({
  required int studentId,
  required String studentName,
  required int activityId,
  required String activityName,
}) {
  return jsonEncode({
    'studentId':    studentId,
    'studentName':  studentName,
    'activityId':   activityId,
    'activityName': activityName,
    'timestamp':    DateTime.now().toUtc().toIso8601String(),
  });
}
```

Other helper methods: `studentQrData`, `activityQrData`, `visitorQrData`.

### Scanning Side (Guard)

In mock mode the guard dashboard rotates through 6 hardcoded `_mockQrPayloads`.  
Each payload is sent to `ApiService().processQrScan(payload)` which in mock mode calls `MockDataService().addQrScan(data)` and returns the scan record.

In real-backend mode the guard app would use a camera plugin (e.g., `mobile_scanner`) to decode a physical QR code, parse the JSON, and POST it to `POST /api/attendance/qr-checkin`:

```
POST /api/attendance/qr-checkin
Body: { qr_data: "{...JSON...}", activity_id?, notes? }

Backend: parses qr_data, extracts studentId, inserts into attendance table
Response: { success, data: { id, student_name, activity_name, check_in_time } }
```

### Backend QR generation (`backend/utils/qrGenerator.js`)

The backend can also generate QR codes server-side using the `qrcode` npm package:

```js
generateStudentQRData(student)  // returns JSON string
generateQRCode(data)            // returns base64 PNG data-URL
```

---

## 7. Admission Form – Data Model & Validation

### Fields Collected

| Field | Type | Validation |
|---|---|---|
| `student_name` | String | Required, non-empty |
| `mother_contact` | String (10 digits) | Required, exactly 10 digits |
| `father_contact` | String (10 digits) | Required, exactly 10 digits |
| `dob` | Date (ISO `YYYY-MM-DD`) | Required, must be selected via date picker |
| `school` | String | Required, non-empty |
| `gender` | Enum: Male / Female / Other | Required (defaults to Male) |
| `hear_about_us` | Enum: Friends / Social Media / Posters / Events | Required (defaults to Friends) |
| `payment_period` | Enum: Monthly / Quarterly / Yearly | Required (defaults to Monthly) |
| `payment_mode` | Enum: Cash / Online | Required (defaults to Cash) |
| `transaction_id` | String | **Conditionally required** when `payment_mode == Online` |

### Validation Logic (`admission_form.dart`)

```dart
// Phone validator – applied to both mother and father contact
validator: (v) {
  if (v == null || v.trim().isEmpty) return '$label is required';
  if (v.trim().length != 10) return 'Enter a valid 10-digit number';
  return null;
}

// Transaction ID conditional validator
validator: (v) {
  if (_paymentMode == 'Online' && (v == null || v.trim().isEmpty)) {
    return 'Transaction ID is required for Online payment';
  }
  return null;
}

// DOB – checked separately before submit (not via FormField)
if (_dob == null) {
  ScaffoldMessenger.of(context).showSnackBar(...);
  return;
}
```

### Submission Payload

```dart
final data = {
  'student_name':   _nameCtrl.text.trim(),
  'mother_contact': _motherPhoneCtrl.text.trim(),
  'father_contact': _fatherPhoneCtrl.text.trim(),
  'dob':            _dob!.toIso8601String().split('T').first,
  'school':         _schoolCtrl.text.trim(),
  'gender':         _gender,
  'hear_about_us':  _hearAboutUs,
  'payment_period': _paymentPeriod,
  'payment_mode':   _paymentMode,
  if (_paymentMode == 'Online') 'transaction_id': _transactionIdCtrl.text.trim(),
};
await ApiService().submitAdmission(data);
```

`ApiService.submitAdmission` in mock mode:
1. Calls `MockDataService().addAdmission(data)` (adds to in-memory list + increments ID)
2. Appends the admission as JSON to the `admissions_data` key in `SharedPreferences` so it **survives an app restart**

---

## 8. Mock API / Data Layer

### `MockDataService` (`services/mock_data_service.dart`)

A **singleton** (`factory MockDataService()` returns `_instance`).  
Holds all in-memory data as private `List` / `Map` fields:

| Field | Type | Content |
|---|---|---|
| `_students` | `List<StudentModel>` | 22 pre-seeded students |
| `_activities` | `List<ActivityModel>` | 10 activities |
| `_attendance` | `List<AttendanceModel>` | Pre-seeded records |
| `_visitors` | `List<VisitorModel>` | Pre-seeded visitors |
| `_enrollments` | `Map<int, List<int>>` | activityId → [studentIds] |
| `_qrScanHistory` | `List<Map>` | Lazily seeded on first read |
| `_admissions` | `List<Map>` | Initially empty; grows with form submissions |

### The 10 Activities

1. Swimming  
2. Yoga  
3. Self-Defence  
4. Phonix  
5. Art & Craft  
6. Sanskrit  
7. Speech & Drama  
8. Indian Culture and Value for Kids  
9. Bharat Natiyam  
10. Music & Movement

### Mock Data Flow

```
ApiService.getStudents()
  └─ _isMockToken? true
       └─ MockDataService().getStudents()
            └─ returns List.unmodifiable(_students)

ApiService.submitAdmission(data)
  └─ _isMockToken? true
       └─ MockDataService().addAdmission(data)  ← in-memory
       └─ SharedPreferences.setString('admissions_data', jsonEncode([...]))  ← persisted
```

### `ApiService` (`services/api_service.dart`)

- **Singleton** pattern via factory constructor
- Wraps all HTTP methods (`_get`, `_post`, `_put`, `_delete`) with 15-second timeout
- Backend base URL: `http://127.0.0.1:5000/api` (configurable via `AppUrls.baseUrl`)
- All responses must follow the shape `{ success, message, statusCode, data }`
- Paginated list endpoints additionally include a `pagination` object

---

## 9. Current Persistence Approach

### What IS Persisted (survives app restart)

| Data | Storage | Key |
|---|---|---|
| Auth token | `SharedPreferences` | `auth_token` |
| Current user (role, name, email) | `SharedPreferences` | `user_data` |
| Submitted admissions | `SharedPreferences` | `admissions_data` |

### What is NOT Persisted (lost on app restart)

| Data | Reason |
|---|---|
| Students, activities, attendance, visitors | In-memory mock singleton only |
| QR scan history | In-memory mock singleton only |

### SharedPreferences Internals

- Android: stored in an XML file at  
  `/data/data/<package_name>/shared_prefs/FlutterSharedPreferences.xml`
- Windows: stored in the Windows Registry under `HKCU\Software\<company>\<app>`
- Values are plain strings; complex objects are JSON-encoded with `dart:convert`

---

## 10. Node.js Backend & PostgreSQL Schema

### Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js (Express 4) |
| Database | PostgreSQL (via `node-postgres` / `pg` pool) |
| Auth | JWT (`jsonwebtoken`) + `bcryptjs` for passwords |
| Rate limiting | `express-rate-limit` (200 req / 15 min global; 20 for auth) |

### Database Tables

```sql
users        – staff accounts (guard, teacher, principal, admin)
students     – enrolled children
activities   – the 10 activity types
enrollments  – many-to-many: students ↔ activities
attendance   – check-in/out records
admissions   – new student admission requests from the form
enquiries    – general enquiry form submissions
visitors     – visitor check-in/out log
```

### API Routes

| Method | Path | Role Required | Description |
|---|---|---|---|
| POST | `/api/auth/login` | Public | Login, returns JWT |
| GET | `/api/students` | Any authenticated | List students (paginated) |
| POST | `/api/students` | teacher / principal / admin | Create student |
| GET | `/api/activities` | Any authenticated | List activities |
| POST | `/api/attendance/checkin` | guard / teacher | Mark attendance |
| POST | `/api/attendance/qr-checkin` | guard | QR-based check-in |
| GET | `/api/dashboard/guard` | guard | Guard stats |
| GET | `/api/dashboard/teacher` | teacher | Teacher stats |
| GET | `/api/dashboard/principal` | principal | Principal stats |
| POST | `/api/admissions` | teacher / principal | Submit new admission |
| GET | `/api/admissions` | principal / admin | List admissions |

### Running the Backend

```bash
cd backend
cp .env.example .env          # fill in DB credentials
npm install
node setup-db.js              # create tables + seed default admin
npm start                     # starts on port 5000
```

Health check: `GET http://localhost:5000/health`

---

## 11. Adding a Real Database (SQLite / Firebase / Backend)

### Option A: Connect to the Existing Node.js + PostgreSQL Backend

1. Install PostgreSQL and create a database:
   ```sql
   CREATE DATABASE iskcon_db;
   ```
2. Fill in `backend/.env`:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=iskcon_db
   DB_USER=postgres
   DB_PASSWORD=your_password
   JWT_SECRET=your_jwt_secret
   ```
3. Run `node setup-db.js` to apply `schema.sql` + `seed.sql`.
4. Start the backend: `npm start` inside `backend/`.
5. In `flutter_app/lib/utils/constants.dart` update `AppUrls.baseUrl`:
   ```dart
   // For Android emulator pointing to host machine:
   static const String baseUrl = 'http://10.0.2.2:5000/api';
   // For physical device on same WiFi:
   static const String baseUrl = 'http://192.168.1.X:5000/api';
   ```
6. Log in with real credentials (`admin@iskcon.org` / `Admin@123`).  
   The app detects a real JWT (not `mock_token_iskcon_dev`) and switches all calls to live HTTP.

---

### Option B: Add SQLite to Flutter (sqflite)

Add to `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.9.0
```

Create `lib/services/database_service.dart`:
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'iskcon.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admissions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        dob         TEXT,
        school      TEXT,
        gender      TEXT,
        mother_contact TEXT,
        father_contact TEXT,
        hear_about_us  TEXT,
        payment_period TEXT,
        payment_mode   TEXT,
        transaction_id TEXT,
        admission_date TEXT
      )
    ''');
  }

  static Future<int> insertAdmission(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('admissions', data);
  }

  static Future<List<Map<String, dynamic>>> getAdmissions() async {
    final db = await database;
    return db.query('admissions', orderBy: 'id DESC');
  }
}
```

Then call `DatabaseService.insertAdmission(data)` inside `ApiService.submitAdmission`.

#### Viewing the SQLite file on Android (emulator)

1. Run the app on the emulator.
2. In Android Studio → **View → Tool Windows → Device Explorer**
3. Navigate to:  
   `data/data/com.example.iskcon_activity_management/databases/iskcon.db`
4. Right-click → **Save As** → open with [DB Browser for SQLite](https://sqlitebrowser.org/)

---

### Option C: Add Firebase Firestore

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android / iOS app and download `google-services.json`
3. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^2.27.0
     cloud_firestore: ^4.15.0
   ```
4. In `main()`:
   ```dart
   await Firebase.initializeApp();
   ```
5. Write admission:
   ```dart
   await FirebaseFirestore.instance
     .collection('admissions')
     .add(data);
   ```
6. Read all admissions:
   ```dart
   final snap = await FirebaseFirestore.instance
     .collection('admissions')
     .orderBy('admissionDate', descending: true)
     .get();
   final records = snap.docs.map((d) => d.data()).toList();
   ```
7. View data live in the Firebase Console → Firestore → admissions collection.

---

## 12. Verifying Stored Records at Runtime

### 12.1 In-App Data Inspector (Built-In)

The app includes a **Data Inspector** screen accessible from the Principal Dashboard app bar (storage icon `🗄`).

It shows:
- **Session** – logged-in user, role, token type (mock / real JWT)
- **Admissions** – every admission submitted this session (from `MockDataService`) + all previously persisted admissions (from `SharedPreferences`)
- **QR Scan History** – every QR scan processed this session

Open it: **Login as Principal → tap the `storage` icon in the top-right app bar**.

---

### 12.2 Debug Console (Flutter)

Run in debug mode:
```bash
cd flutter_app
flutter run
```

`ApiService.submitAdmission` prints:
```
[AdmissionSaved] id=1 student=John Doe date=2026-03-18
```

Add a `debugPrint` anywhere in `MockDataService.addAdmission`:
```dart
debugPrint('[MockDB] Admission added: ${admission['student_name']} #${admission['id']}');
```

---

### 12.3 SharedPreferences Inspector

After submitting admissions, read them back programmatically:

```dart
final prefs = await SharedPreferences.getInstance();
final raw = prefs.getString('admissions_data') ?? '[]';
final list = jsonDecode(raw) as List<dynamic>;
debugPrint('Stored admissions count: ${list.length}');
for (final a in list) debugPrint('  → ${a['student_name']} | ${a['admissionDate']}');
```

On Android you can also inspect the raw XML:

```bash
adb shell run-as com.example.iskcon_activity_management \
  cat shared_prefs/FlutterSharedPreferences.xml
```

---

### 12.4 Backend / PostgreSQL Verification

If the Node.js backend is running and the Flutter app is using a real JWT:

```bash
# Check admissions via API
curl -H "Authorization: Bearer <token>" http://localhost:5000/api/admissions

# Or directly in psql
psql -U postgres -d iskcon_db -c "SELECT * FROM admissions ORDER BY id DESC LIMIT 10;"

# Attendance
psql -U postgres -d iskcon_db -c "SELECT a.*, s.name, act.name FROM attendance a JOIN students s ON s.id=a.student_id JOIN activities act ON act.id=a.activity_id ORDER BY check_in_time DESC LIMIT 10;"
```

Use **pgAdmin** or **TablePlus** as a GUI to browse all tables visually.

---

### 12.5 Postman

The repository includes a complete Postman collection and environment:
- `postman/ISKCON_Activity_Management_API.postman_collection.json`
- `postman/environment.postman_environment.json`

Import both into Postman, set `base_url` to `http://localhost:5000`, run the **Login** request to get a JWT, then call any endpoint to verify records.

---

*End of Architecture Document*
