import { MySQLConnection } from './DB/mysql.js'
import { connectPostgres } from "./DB/postgres.js";
import { 
  initialization, testConnections, transferUsers, levelPermissions, countries, currencies, 
  companies, overSeasOffices, paymentTerms, destinations, banks, productTypes, products, 
  fabrics, fabricSupplier, colors, factories, factoryBanks, couriers, tnaActions, fobTypes, 
  freightTerm, buyers, buyerPaymentTerms, buyerDestinations, buyerConsignees, buyerBanks,
  buyerAdditionalClause, buyerLatePolicies, buyerBrand, buyerDepartments, buyerDepartmentSizes,
  seasons, teams, teamMember, companyBank, buyerOrders, orderDetails, shipmentDetails, 
  shipmentItemDetails,

  loadAuthorizations, loadDepartments, loadLevels, loadModules
} from './func/index.js'
import dotenv from "dotenv";

dotenv.config();

// Database Connections
const mysqlConn = await MySQLConnection();
const pgPool = connectPostgres();

try {
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
  // await fabricSupplier(mysqlConn, pgPool);
  // await colors(mysqlConn, pgPool);
  // await factories(mysqlConn, pgPool);
  // await factoryBanks(mysqlConn, pgPool);
  // await couriers(mysqlConn, pgPool);
  // await tnaActions(mysqlConn, pgPool);
  // await fobTypes(mysqlConn, pgPool);
  // await freightTerm(mysqlConn, pgPool);
  // await buyers(mysqlConn, pgPool);
  // await buyerPaymentTerms(mysqlConn, pgPool);
  // await buyerDestinations(mysqlConn, pgPool);
  // await buyerConsignees(mysqlConn, pgPool);
  // await buyerBanks(mysqlConn, pgPool);
  // await buyerAdditionalClause(mysqlConn, pgPool);
  // await buyerLatePolicies(mysqlConn, pgPool);
  // await buyerBrand(mysqlConn, pgPool);
  // await buyerDepartments(mysqlConn, pgPool);
  // await buyerDepartmentSizes(mysqlConn, pgPool);
  // await seasons(mysqlConn, pgPool);
  // await teams(mysqlConn, pgPool);
  // await teamMember(mysqlConn, pgPool);
  // await companyBank(mysqlConn, pgPool);
  // await buyerOrders(mysqlConn, pgPool);
  // await orderDetails(mysqlConn, pgPool);
  // await shipmentDetails(mysqlConn, pgPool);
  await shipmentItemDetails(mysqlConn, pgPool);
}
catch (error) {
    console.error('Error during migration:', error);
}
finally {
  // Close Connections
  await mysqlConn.end(); // close MySQL connection
  console.log('MySQL connection closed.');

  await pgPool.end(); // close connection pool
  console.log('Postgres pool closed.');
}