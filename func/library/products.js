import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const products = async (mysqlConn, pgPool) => {
    console.log(`Transferring products...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM products`);

    if (!rows.length) {
        console.log(`No data in products to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from products.`);
    }

    let data = rows.map(({id, product_name, product_type_id, active_status}) => ({
        old_pk: id,
        name: product_name,
        old_product_type_id: product_type_id,
        is_active: active_status === 'Y' ? true : false
    }));

    const values = data.map(p => [
        p.name,
        p.old_product_type_id,
        p.is_active,
        p.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO products (
                name, old_product_type_id, is_active, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into products - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }
    
    console.log(`Updating product_type_id in products based on migrated product_types...`);

    await pgPool.query(`UPDATE products p
        SET product_type_id = pt.id
        FROM product_types pt
        WHERE p.old_product_type_id = pt.old_pk;
    `);

    console.log(`Completed transferring products.`);
}