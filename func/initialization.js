import fs from "fs";


export const initialization = async (mysqlConn, pgPool) => {
    console.log(`Initializing target database...`);
    
    const sql = fs.readFileSync("./func/sql/initialization.sql", "utf8");

    const statements = sql.split(/;\s*$/m).map(s => s.trim()).filter(Boolean);

    for (const statement of statements) {
        await pgPool.query(statement);
    }

    const triggers_sql = fs.readFileSync("./func/sql/triggers.sql", "utf8");

    const triggers_statements = triggers_sql.split(/;\s*$/m).map(s => s.trim()).filter(Boolean);
    
    for (const statement of triggers_statements) {
        await pgPool.query(statement);
    }

    console.log(`Target database initialized.`);

}