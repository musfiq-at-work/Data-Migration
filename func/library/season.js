import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const seasons = async (mysqlConn, pgPool) => {
    console.log(`Transferring seasons...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM seasons`);  

    if (!rows.length) {
        console.log(`No data in seasons to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from seasons.`);
    }

    let data = rows.map(({id, buyer_id, season, active_status}) => ({
        old_pk: parseInt(id),
        season_name: season,
        old_buyer_id: parseInt(buyer_id),
        active_status: active_status === 'Y' ? true : false
    }));

    const values = data.map(season => [
        season.season_name,
        season.active_status,
        season.old_buyer_id,
        season.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO seasons (
                season_name, active_status, old_buyer_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into seasons - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_id in seasons...`);
    await pgPool.query(`UPDATE seasons s
        SET buyer_id = b.id
        FROM buyers b
        WHERE s.old_buyer_id = b.old_pk;
    `);

    // await pgPool.query(`DELETE FROM seasons WHERE buyer_id IS NULL;`);

    console.log(`Completed transferring seasons.`);
}