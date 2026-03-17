-- ISKCON Activity Management System - Seed Data
-- Run this script after init.sql to populate the database with initial data

-- Admin user (password: Admin123)
-- bcrypt hash for 'Admin123' with 10 salt rounds
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES (
    'System Admin',
    'admin@iskcon.org',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'admin',
    false
)
ON CONFLICT (email) DO NOTHING;

-- Sample teacher user (password: Teacher123)
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES (
    'Prabhupada Das',
    'teacher@iskcon.org',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'teacher',
    false
)
ON CONFLICT (email) DO NOTHING;

-- Sample students
INSERT INTO students (student_id, name, email, phone, parent_name, parent_phone, class_name, section, address, date_of_birth)
VALUES
    ('STU001', 'Arjun Sharma', 'arjun.sharma@example.com', '9876543210', 'Rajesh Sharma', '9876543211', 'Class 5', 'A', '12 Vrindavan Nagar, Mathura', '2014-03-15'),
    ('STU002', 'Radha Patel', 'radha.patel@example.com', '9876543220', 'Suresh Patel', '9876543221', 'Class 6', 'B', '45 Govardhan Road, Vrindavan', '2013-07-22'),
    ('STU003', 'Krishna Kumar', 'krishna.kumar@example.com', '9876543230', 'Mohan Kumar', '9876543231', 'Class 4', 'A', '78 Yamuna Vihar, Delhi', '2015-11-10'),
    ('STU004', 'Meera Singh', 'meera.singh@example.com', '9876543240', 'Vikram Singh', '9876543241', 'Class 7', 'C', '22 Dwarka Sector 5, Delhi', '2012-05-28'),
    ('STU005', 'Gopal Verma', 'gopal.verma@example.com', '9876543250', 'Ramesh Verma', '9876543251', 'Class 3', 'B', '56 Gokul Colony, Mathura', '2016-09-04'),
    ('STU006', 'Tulsi Gupta', 'tulsi.gupta@example.com', '9876543260', 'Dinesh Gupta', '9876543261', 'Class 8', 'A', '99 Brij Vihar, Agra', '2011-01-18'),
    ('STU007', 'Hari Prasad', 'hari.prasad@example.com', '9876543270', 'Shiv Prasad', '9876543271', 'Class 5', 'C', '33 Madhav Nagar, Vrindavan', '2014-06-30'),
    ('STU008', 'Sita Devi', 'sita.devi@example.com', '9876543280', 'Ram Devi', '9876543281', 'Class 6', 'A', '67 Radha Kunj, Mathura', '2013-12-05')
ON CONFLICT (student_id) DO NOTHING;

-- Sample activities
INSERT INTO activities (name, description, type, location, schedule, start_date, end_date, max_students, teacher, age_group, capacity)
VALUES
    (
        'Bhagavad Gita Study',
        'Weekly study of Bhagavad Gita shlokas with explanation and discussion',
        'spiritual',
        'Main Hall',
        'Every Saturday 9:00 AM - 11:00 AM',
        '2024-01-06',
        '2024-12-28',
        30,
        'Prabhupada Das',
        '10-18 years',
        30
    ),
    (
        'Vedic Mathematics',
        'Learn ancient Indian mathematical techniques for fast calculations',
        'academic',
        'Classroom 1',
        'Monday and Wednesday 3:00 PM - 4:30 PM',
        '2024-01-08',
        '2024-12-25',
        25,
        'Prabhupada Das',
        '8-15 years',
        25
    ),
    (
        'Classical Dance (Bharatanatyam)',
        'Traditional Indian classical dance form based on devotional themes',
        'arts',
        'Dance Studio',
        'Tuesday and Thursday 4:00 PM - 5:30 PM',
        '2024-01-09',
        '2024-12-26',
        20,
        'Meera Lakshmi',
        '6-16 years',
        20
    ),
    (
        'Sanskrit Chanting',
        'Learn Vedic mantras, shlokas, and Sanskrit pronunciation',
        'spiritual',
        'Temple Hall',
        'Daily 6:00 AM - 7:00 AM',
        '2024-01-01',
        '2024-12-31',
        40,
        'Prabhupada Das',
        '5-18 years',
        40
    ),
    (
        'Kirtan and Devotional Music',
        'Learn mridanga, harmonium, and devotional singing',
        'arts',
        'Music Room',
        'Friday 5:00 PM - 7:00 PM',
        '2024-01-05',
        '2024-12-27',
        15,
        'Govinda Das',
        '8-18 years',
        15
    ),
    (
        'Yoga and Meditation',
        'Traditional yoga asanas and meditation techniques',
        'wellness',
        'Yoga Hall',
        'Daily 7:00 AM - 8:00 AM',
        '2024-01-01',
        '2024-12-31',
        35,
        'Prabhupada Das',
        '10-18 years',
        35
    ),
    (
        'Cow Care and Seva',
        'Practical training in cow care, feeding, and service (goseva)',
        'service',
        'Gaushala',
        'Every Sunday 8:00 AM - 10:00 AM',
        '2024-01-07',
        '2024-12-29',
        20,
        'Nanda Das',
        '10-18 years',
        20
    )
ON CONFLICT DO NOTHING;

-- Sample attendance records
INSERT INTO attendance (student_id, activity_id, check_in_time, check_out_time, status)
SELECT
    s.id,
    a.id,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day' + INTERVAL '2 hours',
    'present'
FROM students s
CROSS JOIN activities a
WHERE s.student_id IN ('STU001', 'STU002', 'STU003')
  AND a.name IN ('Bhagavad Gita Study', 'Sanskrit Chanting')
ON CONFLICT DO NOTHING;

-- Sample enquiry
INSERT INTO enquiries (name, email, phone, message, source, status)
VALUES
    (
        'Rajesh Sharma',
        'rajesh.sharma@example.com',
        '9876543211',
        'I would like to enroll my son Arjun in the Bhagavad Gita study program. Please let me know the fee structure and schedule.',
        'website',
        'new'
    ),
    (
        'Sunita Patel',
        'sunita.patel@example.com',
        '9876543222',
        'Interested in classical dance classes for my daughter. What are the requirements and timings?',
        'phone',
        'in_progress'
    )
ON CONFLICT DO NOTHING;
