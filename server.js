import { MySQLConnection } from './DB/mysql.js'
import { connectPostgres } from "./DB/postgres.js";
import { 
  testConnections,
  transferUsers,
  levelPermissions,
  countries,
  currencies,
  companies
} from './func/index.js'
import dotenv from "dotenv";

dotenv.config();

// Database Connections
const mysqlConn = await MySQLConnection();
const pgPool = connectPostgres();

// await testConnections(mysqlConn, pgPool); 
// await transferUsers(mysqlConn, pgPool);
// await levelPermissions(mysqlConn, pgPool);
// await countries(mysqlConn, pgPool);
// await currencies(mysqlConn, pgPool);
// await companies(mysqlConn, pgPool);

// Close Connections
await mysqlConn.end(); // close MySQL connection
console.log('MySQL connection closed.');

await pgPool.end(); // close connection pool
console.log('Postgres pool closed.');