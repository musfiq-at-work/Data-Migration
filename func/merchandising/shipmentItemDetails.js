import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const shipmentItemDetails = async (mysqlConn, pgPool) => {
    console.log(`Transferring shipment_item_details...`);

    console.log(`Cleaning up shipment_detail_colors with null quantities...`);
    await mysqlConn.query(`delete from shipment_detail_colors where color_qty is null;`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM shipment_detail_colors`);

    if (!rows.length) {
        console.log(`No data in shipment_detail_colors to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from shipment_detail_colors.`);
    }

    let data = rows.map(({
        id,
        shipment_detail_id,
        color_id,
        color_qty
    }) => ({
        old_pk: parseInt(id),
        old_shipment_details_id: parseInt(shipment_detail_id),
        old_color_id: parseInt(color_id),
        quantity: parseInt(color_qty)
    }));

    const values = data.map(sid => [
        sid.old_shipment_details_id,
        sid.old_color_id,
        sid.quantity,
        sid.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for(const batch of batches) {
        const query = format(
            `INSERT INTO shipment_item_details (
                old_shipment_details_id, old_color_id, quantity, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into shipment_item_details - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating shipment_details_id and color_id in shipment_item_details...`);
    
    await pgPool.query(`UPDATE shipment_item_details sid
        SET shipment_detail_id = sd.id
        FROM shipment_details sd
        WHERE sid.old_shipment_details_id = sd.old_pk`);

    await pgPool.query(`UPDATE shipment_item_details sid
        SET color_id = c.id
        FROM colors c
        WHERE sid.old_color_id = c.old_pk`);

    await pgPool.query(`delete from shipment_detail_colors where color_qty is null;`);

    console.log(`Completed transferring shipment_item_details.`);
}