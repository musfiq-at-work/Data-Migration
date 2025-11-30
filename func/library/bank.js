import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const banks = async (mysqlConn, pgPool) => {
    console.log(`Transferring banks...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM banks`);

    if (!rows.length) {
        console.log(`No data in banks to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from banks.`);
    }

    let data = rows.map(({id, bank_name}) => ({
        old_pk: id,
        name: bank_name,
    }));

    const values = data.map(b => [
        b.name,
        b.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO banks (
                name, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into banks.`);
        epoch++;
    }

    console.log(`Completed transferring banks.`);
}