import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const overSeasOffices = async (mysqlConn, pgPool) => {
    console.log(`Transferring overseas offices...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM overseas_offices`);

    if (!rows.length) {
        console.log(`No data in overseas_offices to transfer.`);
        return;
    }

    console.log(`Fetched ${rows.length} rows from overseas_offices.`);

    let data = rows.map(({id, name}) => ({
        name,
        currency_id: 1,
        old_pk: id
    }));

    const values = data.map(o => [
        o.name,,
        o.currency_id,
        o.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO OVERSEAS_OFFICES (
                name, currency_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into overseas_offices - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }
    console.log(`Completed transferring overseas offices.`);
}