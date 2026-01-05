import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const factoryShipmentDetails = async (mysqlConn, pgPool) => {
    console.log(`Transferring factory_shipment_details...`);
    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`
        select fo.id as f_id,
            fsd.id,
            fsd.shipment_detail_id,
            fsd.ex_factory_date,
            fsd.base_factory_rate,
            fsd.fob_transfer_rate
        from factory_orders as fo
            inner join factory_order_details as fod on fod.factory_order_id = fo.id
            inner join factory_shipment_details as fsd on fsd.factory_order_detail_id = fod.id;
    `);
    
    if (!rows.length) {
        console.log(`No data in factory_shipment_details to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from factory_shipment_details.`);
    }

    let data = rows.map(({
        id,
        f_id,
        shipment_detail_id,
        ex_factory_date,
        base_factory_rate,
        fob_transfer_rate
    }) => ({
        old_pk: parseInt(id),
        old_factory_order_id: parseInt(f_id),
        old_shipment_detail_id: parseInt(shipment_detail_id),
        exfactory_date: ex_factory_date,
        factory_rate: parseFloat(base_factory_rate),
        transfer_rate: parseFloat(fob_transfer_rate)
    }));

    const values = data.map(fsd => [
        fsd.old_factory_order_id,
        fsd.old_shipment_detail_id,
        fsd.exfactory_date,
        fsd.factory_rate,
        fsd.transfer_rate,
        fsd.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN factory_order_id DROP NOT NULL;`);
    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN shipment_detail_id DROP NOT NULL;`);
    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN exfactory_date DROP NOT NULL;`);

    for (const batch of batches) {
        const query = format(
            `INSERT INTO factory_shipment_details (
                old_factory_order_id, old_shipment_details_id, exfactory_date, factory_rate, transfer_rate, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into factory_shipment_details - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating factory_order_id and shipment_detail_id in factory_shipment_details...`);
    await pgPool.query(`UPDATE factory_shipment_details fsd
        SET factory_order_id = fo.id
        FROM factory_orders fo
        WHERE fsd.old_factory_order_id = fo.old_pk;
    `);

    await pgPool.query(`UPDATE factory_shipment_details fsd
        SET shipment_detail_id = sd.id
        FROM shipment_details sd
        WHERE fsd.old_shipment_details_id = sd.old_pk;
    `);

    await pgPool.query(`
        delete from factory_shipment_details 
            where factory_order_id is null 
            or shipment_detail_id is null 
            or exfactory_date is null;
    `);

    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN factory_order_id SET NOT NULL;`);
    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN shipment_detail_id SET NOT NULL;`);
    await pgPool.query(`ALTER TABLE factory_shipment_details ALTER COLUMN exfactory_date SET NOT NULL;`);

    console.log(`Factory shipment details transfer completed.`);
}