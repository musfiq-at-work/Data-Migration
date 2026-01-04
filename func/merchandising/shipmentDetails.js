import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const shipmentDetails = async (mysqlConn, pgPool) => {
    console.log(`Transferring shipment_details...`);    

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM shipment_details`);
    if (!rows.length) {
        console.log(`No data in shipment_details to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from shipment_details.`);
    }

    let data = rows.map(({
        id,
        order_detail_id,
        buyer_delivery_no,
        buyer_po,
        handover_date,
        etd_date,
        port_id,
        shipment_mode,
        payment_term_id,
        size_set_id,
        lot_qty,
        base_dm_rate
    }) => ({
        old_pk: parseInt(id),
        old_order_style_id: parseInt(order_detail_id),
        serial: buyer_delivery_no,
        buyer_po,
        handover_date,
        etd_date,
        old_destination_id: parseInt(port_id),
        shipment_mode: shipment_mode ? shipment_mode.toUpperCase() : 'SEA',
        old_payment_term_id: parseInt(payment_term_id),
        old_size_id: parseInt(size_set_id),
        lot_quantity: parseInt(lot_qty),
        fob_rate: parseFloat(base_dm_rate)
    }));

    const values = data.map(sd => [
        sd.old_order_style_id,
        sd.serial,
        sd.buyer_po,
        sd.handover_date,
        sd.etd_date,
        sd.old_destination_id,
        sd.shipment_mode,
        sd.old_payment_term_id,
        sd.old_size_id,
        sd.lot_quantity,
        sd.fob_rate,
        sd.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO shipment_details (
                old_order_style_id, serial, buyer_po, handover_date, etd_date, old_destination_id,
                shipment_mode, old_payment_term_id, old_size_id, lot_quantity, fob_rate, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into shipment_details - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating order_style_id, destination_id, payment_term_id, and size_id in shipment_details...`);
    await pgPool.query(`UPDATE shipment_details sd
        SET order_style_id = os.id
        FROM order_styles os
        WHERE sd.old_order_style_id = os.old_pk;`
    );

    await pgPool.query(`UPDATE shipment_details sd
        SET destination_id = d.id
        FROM destinations d
        WHERE sd.old_destination_id = d.old_pk;`
    );

    await pgPool.query(`UPDATE shipment_details sd
        SET payment_term_id = pt.id
        FROM payment_terms pt
        WHERE sd.old_payment_term_id = pt.old_pk;`
    );

    await pgPool.query(`UPDATE shipment_details sd
        SET size_id = ss.id
        FROM buyer_department_sizes ss
        WHERE sd.old_size_id = ss.old_pk;`
    );

    console.log(`Cleaning up shipment_details with null order_style_id...`);
    await pgPool.query(`delete from shipment_details where order_style_id is null;`);

    console.log(`Completed transferring shipment_details.`);
};