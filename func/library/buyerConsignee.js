import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerConsignees = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_consignees...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_consignee`);

    if (!rows.length) {
        console.log(`No data in buyer_consignee to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_consignee.`);
    }

    let data = rows.map(({id, sl_no, buyer_id, consignee_name, address }) => ({
        old_pk: parseInt(id),
        sl_no: parseInt(sl_no),
        old_buyer_id: parseInt(buyer_id),
        consignee_name,
        address,
    }));

    const values = data.map(bc => [
        bc.old_buyer_id,
        bc.sl_no,
        bc.consignee_name,
        bc.address,
        bc.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_consignee (
                old_buyer_id, sl_no, consignee_name, address, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_consignee - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating buyer_id in buyer_consignee...`);
    await pgPool.query(`UPDATE buyer_consignee bc
        SET buyer_id = b.id
        FROM buyers b
        WHERE bc.old_buyer_id = b.old_pk
    ;`);

    console.log(`Completed transferring buyer_consignees.`);
};