import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const factoryOrder = async (mysqlConn, pgPool) => {
    console.log(`Transferring factory_orders...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM factory_orders`);

    if (!rows.length) {
        console.log(`No data in factory_orders to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from factory_orders.`);
    }

    let data = rows.map(({
        id,
        order_id,
        factory_order_date,
        approval_status,
    }) => ({
        old_pk: parseInt(id),
        old_order_id: parseInt(order_id),
        factory_order_date,
        approval_status
    }));

    const values = data.map(fo => [
        fo.old_order_id,
        fo.factory_order_date,
        fo.approval_status,
        fo.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO factory_orders (
                old_order_id, factory_order_date, approval_status, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into factory_orders - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating order_id in factory_orders...`);
    await pgPool.query(`UPDATE factory_orders fo
        SET order_id = bo.id
        FROM buyer_orders bo
        WHERE fo.old_order_id = bo.old_pk;`);

    console.log(`Factory orders transfer completed.`);
}