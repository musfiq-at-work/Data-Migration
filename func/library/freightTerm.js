import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const freightTerm = async (mysqlConn, pgPool) => {
    console.log(`Transferring Freight Terms...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM freight_terms`);

    if (!rows.length) {
        console.log(`No data in Freight Terms to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from Freight Terms.`);
    }

    let data = rows.map(({id, term_name}) => ({
        old_pk: id,
        name: term_name
    }));

    const values = data.map(f => [
        f.name,
        f.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO freight_term (
                name, old_pk
            ) VALUES %L`,
            batch
        );

        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into Freight Terms - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring Freight Terms.`);
}