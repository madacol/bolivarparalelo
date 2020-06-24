import { Pool } from 'pg';

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    query_timeout: 10000,
    max: 6,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
})

export default pool