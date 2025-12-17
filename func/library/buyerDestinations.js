import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerDestinations = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_destinations...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyers`);

    if (!rows.length) {
        console.log(`No data in buyers to transfer buyer_destinations.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyers for buyer_destinations.`);
    }

    let data = rows.map(({id, destination }) => ({
        old_buyer_id: parseInt(id),
        old_destination_id: destination,
    }));

    const destinations = [];
    data.forEach(bd => {
        if (bd.old_destination_id) {
            const destIds = bd.old_destination_id.split(',').map(id => parseInt(id.trim()));
            destIds.forEach(destId => {
                destinations.push({
                    old_buyer_id: bd.old_buyer_id,
                    old_destination_id: destId,
                });
            });
        }   
    })
    
    const values = destinations.map(bd => [
        bd.old_buyer_id,
        bd.old_destination_id
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(values.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_destinations (
                old_buyers_id, old_destinations_id
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_destinations - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating buyer_id and destination_id in buyer_destinations...`);
    await pgPool.query(`UPDATE buyer_destinations bd
        SET buyer_id = b.id
        FROM buyers b
        WHERE bd.old_buyers_id = b.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_destinations bd
        SET destinations_id = d.id
        FROM destinations d
        WHERE bd.old_destinations_id = d.old_pk;`
    );

    await pgPool.query(`DELETE FROM buyer_destinations WHERE buyer_id IS NULL OR destinations_id IS NULL;`);

    console.log(`Completed transferring buyer_destinations.`);
}