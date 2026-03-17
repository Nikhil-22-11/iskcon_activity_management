/**
 * ISKCON Activity Management System - Database Setup Script
 *
 * Usage: npm run setup-db
 *
 * This script:
 *  1. Connects to PostgreSQL using credentials from .env
 *  2. Creates the database if it does not exist
 *  3. Runs init.sql to create all tables
 *  4. Runs seed.sql to insert initial/sample data
 */

require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const {
  DB_HOST = 'localhost',
  DB_PORT = '5432',
  DB_USER = 'postgres',
  DB_PASSWORD,
  DB_NAME = 'iskcon_activity_db',
} = process.env;

if (!DB_PASSWORD) {
  console.error('❌  DB_PASSWORD is not set. Please configure your .env file.');
  console.error('    Copy .env.example to .env and fill in your PostgreSQL credentials.');
  process.exit(1);
}

const baseConfig = {
  host: DB_HOST,
  port: parseInt(DB_PORT, 10),
  user: DB_USER,
  password: String(DB_PASSWORD),
  database: 'postgres', // connect to default DB first to create our DB
};

const dbConfig = {
  ...baseConfig,
  database: DB_NAME,
};

async function ensureDatabase() {
  const client = new Client(baseConfig);
  try {
    await client.connect();
    console.log('✅  Connected to PostgreSQL server');

    const result = await client.query(
      'SELECT 1 FROM pg_database WHERE datname = $1',
      [DB_NAME]
    );

    if (result.rowCount === 0) {
      await client.query(`CREATE DATABASE "${DB_NAME}"`);
      console.log(`✅  Database "${DB_NAME}" created`);
    } else {
      console.log(`ℹ️   Database "${DB_NAME}" already exists`);
    }
  } finally {
    await client.end();
  }
}

async function runSqlFile(client, filePath) {
  const sql = fs.readFileSync(filePath, 'utf8');
  await client.query(sql);
  console.log(`✅  Executed: ${path.basename(filePath)}`);
}

async function setup() {
  console.log('\n🚀  ISKCON Activity Management - Database Setup\n');
  console.log(`    Host     : ${DB_HOST}:${DB_PORT}`);
  console.log(`    User     : ${DB_USER}`);
  console.log(`    Database : ${DB_NAME}`);
  console.log('');

  // Step 1: Make sure the target database exists
  await ensureDatabase();

  // Step 2: Connect to the target database and run SQL scripts
  const client = new Client(dbConfig);
  try {
    await client.connect();

    const initSql = path.join(__dirname, 'database', 'init.sql');
    const seedSql = path.join(__dirname, 'database', 'seed.sql');

    await runSqlFile(client, initSql);
    await runSqlFile(client, seedSql);

    console.log('\n🎉  Database setup complete!');
    console.log('\n    You can now start the backend server:');
    console.log('      npm run dev\n');
    console.log('    Default admin credentials:');
    console.log('      Email   : admin@iskcon.org');
    console.log('      Password: Admin123\n');
  } catch (err) {
    console.error('\n❌  Database setup failed:', err.message);
    console.error('\n    Troubleshooting:');
    console.error('    • Make sure PostgreSQL is running');
    console.error('    • Verify your credentials in backend/.env');
    console.error('    • Ensure the PostgreSQL user has CREATE DATABASE privileges');
    process.exit(1);
  } finally {
    await client.end();
  }
}

setup();
