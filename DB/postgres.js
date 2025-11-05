import pkg from "pg";
const { Pool } = pkg;


export function connectPostgres() {
    const pgPool = new Pool({
        host: process.env.PG_HOST,
        user: process.env.PG_USER,
        password: process.env.PG_PASSWORD,
        database: process.env.PG_DATABASE,
        port: process.env.PG_PORT ? parseInt(process.env.PG_PORT) : 5432,
    });

    return pgPool;
}
