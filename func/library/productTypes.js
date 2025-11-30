import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const productTypes = async (mysqlConn, pgPool) => {
    console.log(`Transferring product types...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM product_types`);

    if (!rows.length) {
        console.log(`No data in product types to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from product types.`);
    }

    let data = rows.map(({id, product_type, active_status}) => ({
        old_pk: id,
        name: product_type,
        is_active: active_status === 'Y' ? true : false
    }));

    const values = data.map(pt => [
        pt.name,
        pt.is_active,
        pt.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO product_types (
                name, is_active, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into product types.`);
        epoch++;
    }

    console.log(`Completed transferring product types.`);
}