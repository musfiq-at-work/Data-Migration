import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const colors = async (mysqlConn, pgPool) => {
    console.log(`Transferring colors...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM colors`);

    if (!rows.length) {
        console.log(`No data in colors to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from colors.`);
    }

    let data = rows.map(({id, color_name}) => ({
        old_pk: parseInt(id),
        name: color_name,
    }));

    const values = data.map(c => [
        c.name,
        c.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO colors (
                name, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into colors - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring colors.`);
}