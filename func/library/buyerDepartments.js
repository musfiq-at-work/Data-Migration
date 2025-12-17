import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerDepartments= async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_departments...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_departments`);
    if (!rows.length) {
        console.log(`No data in buyer_departments to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_departments.`);
    }

    let data = rows.map(({id,  buyer_brand_id, department }) => ({
        old_pk: parseInt(id),
        old_buyer_brand_id: parseInt(buyer_brand_id),
        department
    }));

    const values = data.map(bb => [
        bb.old_buyer_brand_id,
        bb.department,
        bb.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_departments (
                old_buyer_brand_id, department, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_departments - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_brand_id in buyer_departments...`);
    await pgPool.query(`UPDATE buyer_departments bd
        SET buyer_brand_id = b.id
        FROM buyers b
        WHERE bd.old_buyer_brand_id = b.old_pk;
    `);

    // await pgPool.query(`DELETE FROM buyer_departments WHERE buyer_brand_id IS NULL;`);

    console.log(`Completed transferring buyer_departments.`);
}