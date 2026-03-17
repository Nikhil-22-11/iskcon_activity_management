-- ISKCON Activity Management System - Database Schema
-- Run this script to create all required tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (teachers, guards, principals, admins)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'teacher', 'guard', 'principal')),
    is_active BOOLEAN DEFAULT true,
    must_change_password BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Students table
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(15),
    parent_name VARCHAR(100),
    parent_phone VARCHAR(15),
    class_name VARCHAR(50),
    section VARCHAR(10),
    address TEXT,
    date_of_birth DATE,
    photo_url TEXT,
    qr_code TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Activities table
CREATE TABLE IF NOT EXISTS activities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    type VARCHAR(50),
    location VARCHAR(150),
    schedule VARCHAR(100),
    start_date DATE,
    end_date DATE,
    max_students INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enrollments table (students enrolled in activities)
CREATE TABLE IF NOT EXISTS enrollments (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    activity_id INTEGER NOT NULL REFERENCES activities(id),
    enrolled_at TIMESTAMP DEFAULT NOW(),
    enrolled_by INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(student_id, activity_id)
);

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    activity_id INTEGER REFERENCES activities(id),
    check_in_time TIMESTAMP NOT NULL DEFAULT NOW(),
    check_out_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'present' CHECK (status IN ('present', 'absent', 'late')),
    marked_by INTEGER REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Enquiries table
CREATE TABLE IF NOT EXISTS enquiries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(15),
    message TEXT NOT NULL,
    source VARCHAR(50) DEFAULT 'website',
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'resolved', 'closed')),
    notes TEXT,
    assigned_to INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Visitors table
CREATE TABLE IF NOT EXISTS visitors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    purpose TEXT NOT NULL,
    host_name VARCHAR(100),
    id_type VARCHAR(50),
    id_number VARCHAR(50),
    photo_url TEXT,
    check_in_time TIMESTAMP NOT NULL DEFAULT NOW(),
    check_out_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'checked_in' CHECK (status IN ('checked_in', 'checked_out')),
    notes TEXT,
    checked_in_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_students_student_id ON students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_name ON students(name);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_check_in_time ON attendance(check_in_time);
CREATE INDEX IF NOT EXISTS idx_attendance_activity_id ON attendance(activity_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_activity_id ON enrollments(activity_id);
CREATE INDEX IF NOT EXISTS idx_visitors_check_in_time ON visitors(check_in_time);
CREATE INDEX IF NOT EXISTS idx_enquiries_status ON enquiries(status);

-- Default admin user (password: Admin@123)
-- bcrypt hash for 'Admin@123' with 10 salt rounds
INSERT INTO users (name, email, password_hash, role, must_change_password)
VALUES (
    'System Admin',
    'admin@iskcon.org',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'admin',
    false
)
ON CONFLICT (email) DO NOTHING;
