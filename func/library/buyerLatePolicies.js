import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerLatePolicies = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_late_policies...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_late_policys`);

    if (!rows.length) {
        console.log(`No data in buyer_late_policys to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_late_policys.`);
    }

    let data = rows.map(({id, buyer_id, slno, description }) => ({
        old_pk: parseInt(id),
        old_buyer_id: parseInt(buyer_id),
        sl_no: parseInt(slno),
        description,
    }));

    const values = data.map(blp => [
        blp.old_buyer_id,
        blp.sl_no,
        blp.description,
        blp.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_late_policies (
                old_buyers_id, sl_no, description, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_late_policies - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_id in buyer_late_policies...`);
    await pgPool.query(`UPDATE buyer_late_policies blp
        SET buyer_id = b.id
        FROM buyers b
        WHERE blp.old_buyers_id = b.old_pk;
    `);

    await pgPool.query(`DELETE FROM buyer_late_policies WHERE buyer_id IS NULL;`);

    console.log(`Completed transferring buyer_late_policies.`);
}