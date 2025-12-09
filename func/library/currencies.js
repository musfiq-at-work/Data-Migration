import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const currencies = async (mysqlConn, pgPool) => {
    console.log(`Transferring currencies...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM currencies`);
    if (!rows.length) {
        console.log(`No data in currencies to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from currencies.`);
    }

    let data = rows.map(({id, currency_name, short_name, symbol}) => ({
        old_pk: id,
        name: currency_name,
        currency_code: short_name,
        symbol
    }));

    const values = data.map(c => [
        c.name,
        c.currency_code,
        c.symbol,
        c.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1
    for (const batch of batches) {
        const query = format(
            `INSERT INTO currencies (
                name, currency_code, symbol, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into currencies - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring currencies.`);

}