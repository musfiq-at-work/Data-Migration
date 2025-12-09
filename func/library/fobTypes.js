import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const fobTypes = async (mysqlConn, pgPool) => {
    console.log(`Transferring FOB Types...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM fob_types`);
    
    if (!rows.length) {
        console.log(`No data in FOB Types to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from FOB Types.`);
    }

    let data = rows.map(({id, fob_type}) => ({
        old_pk: id,
        name: fob_type,
    }));

    const values = data.map(f => [
        f.name,
        f.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1       

    for (const batch of batches) {
        const query = format(
            `INSERT INTO fob_types (
                name, old_pk
            ) VALUES %L`,
            batch
        );

        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into FOB Types - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring FOB Types.`);
}