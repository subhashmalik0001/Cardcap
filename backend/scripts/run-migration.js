const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const password = process.argv[2];
if (!password) {
  console.error("Error: Please provide your Supabase database password.");
  console.log("Usage: node run-migration.js <supabase_db_password>");
  process.exit(1);
}

// Supabase Connection String (Session Pooler on port 6543)
const connectionString = `postgres://postgres:${encodeURIComponent(password)}@db.zsjinlmpmbxkjghxhoqh.supabase.co:6543/postgres?sslmode=require`;
const client = new Client({
  connectionString,
  ssl: {
    rejectUnauthorized: false
  }
});

async function run() {
  const migrationPath = path.join(__dirname, '../supabase/migrations/20260616120000_update_scan_storage.sql');
  console.log(`Reading migration file: ${migrationPath}`);
  
  if (!fs.existsSync(migrationPath)) {
    console.error("Error: Migration file not found!");
    process.exit(1);
  }
  
  const sql = fs.readFileSync(migrationPath, 'utf8');
  
  try {
    console.log("Connecting to Supabase Postgres...");
    await client.connect();
    console.log("Connected successfully! Executing migration SQL...");
    await client.query(sql);
    console.log("Migration SQL executed successfully!");
  } catch (err) {
    console.error("Migration failed:", err);
  } finally {
    await client.end();
  }
}

run();
