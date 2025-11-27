import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const destinations = async (mysqlConn, pgPool) => {
    console.log(`Transferring destinations...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM ports`);

    if (!rows.length) {
        console.log(`No data in destinations to transfer.`);
        return;
    }

    console.log(`Fetched ${rows.length} rows from destinations.`);

    let data = rows.map(({id, port_name}) => ({
        name: port_name,
        old_pk: id
    }));

    const values = data.map(o => [
        o.name,
        o.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO destinations (
                name, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into destinations.`);
        epoch++;
    }
    console.log(`Completed transferring destinations.`);
}