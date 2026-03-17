/**
 * ISKCON Activity Management System - API Test Suite
 *
 * Run: node tests/testAPI.js
 * Prerequisites:
 *   - PostgreSQL running with iskcon_activity_db
 *   - Backend server running on port 5000
 *   - npm install (in backend/) done
 */

'use strict';

const http = require('http');
const { Client } = require('pg');

// ─── Configuration ────────────────────────────────────────────────────────────

const BASE_URL = process.env.API_BASE_URL || 'http://localhost:5000/api';
const DB_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'iskcon_activity_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Make an HTTP request and return parsed JSON body.
 * @param {string} method
 * @param {string} path
 * @param {object|null} body
 * @param {string|null} token
 * @returns {Promise<{status: number, data: any}>}
 */
function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const payload = body ? JSON.stringify(body) : null;

    const options = {
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname + url.search,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    };

    const req = http.request(options, (res) => {
      let raw = '';
      res.on('data', (chunk) => { raw += chunk; });
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(raw) });
        } catch {
          resolve({ status: res.statusCode, data: raw });
        }
      });
    });

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

// ─── Test runner ──────────────────────────────────────────────────────────────

let passed = 0;
let failed = 0;
const failures = [];

function assert(condition, label) {
  if (condition) {
    console.log(`  ✅  ${label}`);
    passed++;
  } else {
    console.error(`  ❌  ${label}`);
    failed++;
    failures.push(label);
  }
}

async function runGroup(name, fn) {
  console.log(`\n📦 ${name}`);
  console.log('─'.repeat(50));
  await fn();
}

// ─── Test groups ──────────────────────────────────────────────────────────────

async function testDatabaseConnection() {
  const client = new Client(DB_CONFIG);
  try {
    await client.connect();
    const res = await client.query('SELECT 1 AS ok');
    assert(res.rows[0].ok === 1, 'PostgreSQL connection established');

    // Verify all 8 required tables exist
    const tables = ['users', 'students', 'activities', 'enrollments',
      'attendance', 'enquiries', 'visitors', 'payments'];
    for (const table of tables) {
      const check = await client.query(
        `SELECT to_regclass('public.${table}') AS tbl`,
      );
      assert(check.rows[0].tbl !== null, `Table '${table}' exists`);
    }

    // Verify default admin user
    const admin = await client.query(
      "SELECT id FROM users WHERE email = 'admin@iskcon.org' LIMIT 1",
    );
    assert(admin.rows.length > 0, "Default admin user 'admin@iskcon.org' exists");
  } catch (err) {
    assert(false, `Database connection failed: ${err.message}`);
  } finally {
    await client.end().catch(() => {});
  }
}

async function testAuthentication() {
  let token = null;

  // Successful login
  const loginOk = await request('POST', '/auth/login', {
    email: 'admin@iskcon.org',
    password: 'Admin123',
  });
  assert(loginOk.status === 200, 'POST /auth/login returns 200');
  assert(loginOk.data && loginOk.data.success === true, 'Login response has success:true');
  assert(
    loginOk.data && loginOk.data.data && typeof loginOk.data.data.token === 'string',
    'Login response contains JWT token',
  );
  if (loginOk.data && loginOk.data.data) token = loginOk.data.data.token;

  // Invalid credentials
  const loginBad = await request('POST', '/auth/login', {
    email: 'nobody@iskcon.org',
    password: 'wrong',
  });
  assert(loginBad.status === 401, 'POST /auth/login with bad credentials returns 401');

  // Get me (protected)
  if (token) {
    const me = await request('GET', '/auth/me', null, token);
    assert(me.status === 200, 'GET /auth/me returns 200 with valid token');
    assert(
      me.data && me.data.data && me.data.data.email === 'admin@iskcon.org',
      'GET /auth/me returns correct user email',
    );
  }

  // No token → 401
  const noToken = await request('GET', '/students');
  assert(noToken.status === 401, 'GET /students without token returns 401');

  return token;
}

async function testStudents(token) {
  let createdId = null;

  // Create student
  const create = await request('POST', '/students', {
    name: 'Arjun Kumar',
    email: `arjun_${Date.now()}@example.com`,
    phone: '9876543210',
    dateOfBirth: '2015-05-20',
    parentName: 'Rajesh Kumar',
    parentPhone: '9876543211',
    address: '123 Krishna Lane',
  }, token);
  assert([200, 201].includes(create.status), 'POST /students returns 200/201');
  assert(
    create.data && create.data.success === true,
    'POST /students response has success:true',
  );
  if (create.data && create.data.data) createdId = create.data.data.id;

  // Get all students
  const list = await request('GET', '/students?page=1&limit=10', null, token);
  assert(list.status === 200, 'GET /students returns 200');
  assert(Array.isArray(list.data && list.data.data), 'GET /students returns data array');
  assert(
    list.data && list.data.pagination !== undefined,
    'GET /students response has pagination',
  );

  if (createdId) {
    // Get by ID
    const getOne = await request(`GET`, `/students/${createdId}`, null, token);
    assert(getOne.status === 200, `GET /students/${createdId} returns 200`);

    // Update
    const update = await request('PUT', `/students/${createdId}`, {
      name: 'Arjun Kumar Updated',
    }, token);
    assert(update.status === 200, `PUT /students/${createdId} returns 200`);

    // QR code
    const qr = await request('GET', `/students/qr/${createdId}`, null, token);
    assert(qr.status === 200, `GET /students/qr/${createdId} returns 200`);
    assert(
      qr.data && qr.data.data && qr.data.data.qrCode !== undefined,
      'QR code endpoint returns qrCode field',
    );

    // Delete
    const del = await request('DELETE', `/students/${createdId}`, null, token);
    assert(del.status === 200, `DELETE /students/${createdId} returns 200`);
  }

  // Not found
  const notFound = await request('GET', '/students/99999', null, token);
  assert(notFound.status === 404, 'GET /students/99999 returns 404');

  return createdId;
}

async function testActivities(token) {
  let createdId = null;

  // Create activity
  const create = await request('POST', '/activities', {
    name: `Bhagavad Gita Class ${Date.now()}`,
    description: 'Learn Bhagavad Gita teachings',
    schedule: 'Mon, Wed, Fri - 6:00 PM',
  }, token);
  assert([200, 201].includes(create.status), 'POST /activities returns 200/201');
  assert(
    create.data && create.data.success === true,
    'POST /activities response has success:true',
  );
  if (create.data && create.data.data) createdId = create.data.data.id;

  // Get all
  const list = await request('GET', '/activities?page=1&limit=10', null, token);
  assert(list.status === 200, 'GET /activities returns 200');
  assert(Array.isArray(list.data && list.data.data), 'GET /activities returns data array');

  if (createdId) {
    // Get by ID
    const getOne = await request('GET', `/activities/${createdId}`, null, token);
    assert(getOne.status === 200, `GET /activities/${createdId} returns 200`);

    // Update
    const update = await request('PUT', `/activities/${createdId}`, {
      name: 'Bhagavad Gita Class Updated',
    }, token);
    assert(update.status === 200, `PUT /activities/${createdId} returns 200`);

    // Get enrolled students
    const students = await request(
      'GET', `/activities/${createdId}/students`, null, token,
    );
    assert(students.status === 200, `GET /activities/${createdId}/students returns 200`);

    // Delete
    const del = await request('DELETE', `/activities/${createdId}`, null, token);
    assert(del.status === 200, `DELETE /activities/${createdId} returns 200`);
  }

  return createdId;
}

async function testAttendance(token) {
  // Get date-based attendance
  const byDate = await request(
    'GET', '/attendance/date/2026-03-17', null, token,
  );
  assert(byDate.status === 200, 'GET /attendance/date/:date returns 200');

  // Attendance report (admin)
  const report = await request('GET', '/attendance/report', null, token);
  assert(report.status === 200, 'GET /attendance/report returns 200');
}

async function testVisitors(token) {
  let visitorId = null;

  const checkIn = await request('POST', '/visitors/checkin', {
    visitorName: 'Sharma Ji',
    visitorPhone: '9876543212',
    visitReason: 'Student pickup',
    studentName: 'Arjun Kumar',
  }, token);
  assert([200, 201].includes(checkIn.status), 'POST /visitors/checkin returns 200/201');
  assert(
    checkIn.data && checkIn.data.success === true,
    'POST /visitors/checkin response has success:true',
  );
  if (checkIn.data && checkIn.data.data) visitorId = checkIn.data.data.id;

  if (visitorId) {
    const checkOut = await request('PUT', `/visitors/${visitorId}/checkout`, null, token);
    assert(checkOut.status === 200, `PUT /visitors/${visitorId}/checkout returns 200`);
  }

  const list = await request('GET', '/visitors?page=1&limit=10', null, token);
  assert(list.status === 200, 'GET /visitors returns 200');
  assert(Array.isArray(list.data && list.data.data), 'GET /visitors returns data array');

  const byDate = await request('GET', '/visitors/date/2026-03-17', null, token);
  assert(byDate.status === 200, 'GET /visitors/date/:date returns 200');
}

async function testEnquiries(token) {
  let enquiryId = null;

  // Public endpoint – no token required
  const create = await request('POST', '/enquiries', {
    name: 'Priya Singh',
    email: `priya_${Date.now()}@example.com`,
    phone: '9876543213',
    message: 'Interested in joining',
  });
  assert([200, 201].includes(create.status), 'POST /enquiries (public) returns 200/201');
  if (create.data && create.data.data) enquiryId = create.data.data.id;

  const list = await request('GET', '/enquiries?page=1&limit=10', null, token);
  assert(list.status === 200, 'GET /enquiries returns 200');
  assert(Array.isArray(list.data && list.data.data), 'GET /enquiries returns data array');

  if (enquiryId) {
    const getOne = await request('GET', `/enquiries/${enquiryId}`, null, token);
    assert(getOne.status === 200, `GET /enquiries/${enquiryId} returns 200`);

    const update = await request('PUT', `/enquiries/${enquiryId}`, {
      status: 'in_progress',
      notes: 'Contacted by phone',
    }, token);
    assert(update.status === 200, `PUT /enquiries/${enquiryId} returns 200`);
  }
}

async function testDashboard(token) {
  const teacher = await request('GET', '/dashboard/teacher', null, token);
  assert(teacher.status === 200, 'GET /dashboard/teacher returns 200');

  const principal = await request('GET', '/dashboard/principal', null, token);
  assert(principal.status === 200, 'GET /dashboard/principal returns 200');

  const stats = await request('GET', '/dashboard/stats', null, token);
  assert(stats.status === 200, 'GET /dashboard/stats returns 200');
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║   ISKCON Activity Management - API Test Suite            ║');
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log(`\nBase URL : ${BASE_URL}`);
  console.log(`DB Host  : ${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`);
  console.log(`Started  : ${new Date().toISOString()}`);

  let token = null;

  await runGroup('1. Database Connection', testDatabaseConnection);
  await runGroup('2. Authentication', async () => {
    token = await testAuthentication();
  });

  if (!token) {
    console.error('\n⛔  Cannot continue without a valid token. Check credentials and server.');
    printSummary();
    process.exit(1);
  }

  await runGroup('3. Student Management', () => testStudents(token));
  await runGroup('4. Activity Management', () => testActivities(token));
  await runGroup('5. Attendance', () => testAttendance(token));
  await runGroup('6. Visitor Management', () => testVisitors(token));
  await runGroup('7. Enquiry Management', () => testEnquiries(token));
  await runGroup('8. Dashboard', () => testDashboard(token));

  printSummary();
}

function printSummary() {
  const total = passed + failed;
  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║                    TEST SUMMARY                         ║');
  console.log('╠══════════════════════════════════════════════════════════╣');
  console.log(`║  Total  : ${String(total).padEnd(46)}║`);
  console.log(`║  Passed : ${String(passed).padEnd(46)}║`);
  console.log(`║  Failed : ${String(failed).padEnd(46)}║`);
  console.log('╚══════════════════════════════════════════════════════════╝');

  if (failures.length > 0) {
    console.log('\nFailed tests:');
    failures.forEach((f) => console.log(`  ❌ ${f}`));
  }

  const exitCode = failed > 0 ? 1 : 0;
  console.log(
    exitCode === 0
      ? '\n🎉 All tests passed!'
      : `\n⚠️  ${failed} test(s) failed.`,
  );
  process.exit(exitCode);
}

main().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});
