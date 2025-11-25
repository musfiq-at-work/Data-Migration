import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const countries = async (mysqlConn, pgPool) => {
    console.log(`Transferring countries...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM countries`);
    if (!rows.length) {
        console.log(`No data in countries to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from countries.`);
    }

    let data = rows.map(({id, country_name, short_name}) => ({
        old_pk: id,
        name: country_name,
        short_name
    }));

    const values = data.map(c => [
        c.name,
        c.short_name,
        c.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO countries (
                name, short_name, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into countries.`);
        epoch++;
    }

    console.log(`Completed transferring countries.`);

}