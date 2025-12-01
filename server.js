import { MySQLConnection } from './DB/mysql.js'
import { connectPostgres } from "./DB/postgres.js";
import { 
  initialization, testConnections, transferUsers, levelPermissions, countries,
  currencies, companies, overSeasOffices, paymentTerms, destinations,
  banks, productTypes, products, fabrics,

  loadAuthorizations, loadDepartments, loadLevels, loadModules
} from './func/index.js'
import dotenv from "dotenv";

dotenv.config();

// Database Connections
const mysqlConn = await MySQLConnection();
const pgPool = connectPostgres();

// await initialization(mysqlConn, pgPool);
// await loadAuthorizations(pgPool);
// await loadDepartments(pgPool);
// await loadLevels(pgPool);
// await loadModules(pgPool);
// await testConnections(mysqlConn, pgPool); 
// await transferUsers(mysqlConn, pgPool);
// await levelPermissions(mysqlConn, pgPool);
// await countries(mysqlConn, pgPool);
// await currencies(mysqlConn, pgPool);
// await companies(mysqlConn, pgPool);
// await overSeasOffices(mysqlConn, pgPool);
// await paymentTerms(mysqlConn, pgPool);
// await destinations(mysqlConn, pgPool);
// await banks(mysqlConn, pgPool);
// await productTypes(mysqlConn, pgPool);
// await products(mysqlConn, pgPool);
// await fabrics(mysqlConn, pgPool);

// Close Connections
await mysqlConn.end(); // close MySQL connection
console.log('MySQL connection closed.');

await pgPool.end(); // close connection pool
console.log('Postgres pool closed.');