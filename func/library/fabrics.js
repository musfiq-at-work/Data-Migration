import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const fabrics = async (mysqlConn, pgPool) => {
    console.log(`Transferring fabrics...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM fabrics`);

    if (!rows.length) {
        console.log(`No data in fabrics to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from fabrics.`);
    }

    let data = rows.map(({id, product_type_id, fabrics, composition, description, value, v_unit}) => ({
        old_pk: id,
        old_product_type_id: product_type_id,
        name: fabrics,
        composition,
        description,
        value: parseInt(value),
        unit: v_unit
    }));

    const values = data.map(f => [
        f.old_product_type_id,
        f.name,
        f.composition,
        f.description,
        f.value,
        f.unit,
        f.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO fabrics (
                old_product_type_id, name, composition, description, value, unit, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into fabrics - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating product_type_id in fabrics...`);

    await pgPool.query(`UPDATE FABRICS f
        SET product_type_id = pt.id
        FROM product_types pt
        WHERE f.old_product_type_id = pt.old_pk;`
    );

    console.log(`Completed transferring fabrics.`);
}