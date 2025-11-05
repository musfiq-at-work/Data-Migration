export const testConnections = async (mysqlConn, pgPool) => {
    try {
        const [mysqlResult] = await mysqlConn.query("SELECT NOW() AS now");
        console.log("MySQL connected:", mysqlResult[0].now);

        const pgClient = await pgPool.connect();
        const pgResult = await pgClient.query("SELECT NOW()");

        console.log("PostgreSQL connected:", pgResult.rows[0].now);
        pgClient.release();

    } catch (err) {
        console.error("Connection test failed:", err.message);
    } finally {
        await mysqlConn.end();
        await pgPool.end();
    }
}