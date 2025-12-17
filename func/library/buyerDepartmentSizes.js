import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerDepartmentSizes = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_department_sizes...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM size_sets`);

    if (!rows.length) {
        console.log(`No data in size_sets to transfer buyer_department_sizes.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from size_sets for buyer_department_sizes.`);
    }

    let data = rows.map(({id,  buyer_department_id, size_set }) => ({
        old_pk: parseInt(id),
        old_buyer_department_id: parseInt(buyer_department_id),
        size: size_set
    }));

    const values = data.map(bds => [
        bds.old_buyer_department_id,
        bds.size,
        bds.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_department_sizes (
                old_buyer_department_id, size, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_department_sizes - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_department_id in buyer_department_sizes...`);
    await pgPool.query(`UPDATE buyer_department_sizes bds
        SET buyer_department_id = bd.id
        FROM buyer_departments bd
        WHERE bds.old_buyer_department_id = bd.old_pk;
    `);

    // await pgPool.query(`DELETE FROM buyer_department_sizes WHERE buyer_department_id IS NULL;`);

    console.log(`Completed transferring buyer_department_sizes.`);
}