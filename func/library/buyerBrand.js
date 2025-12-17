import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerBrand = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_brands...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_brands`);

    if (!rows.length) {
        console.log(`No data in buyer_brands to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_brands.`);
    }

    let data = rows.map(({id,  buyer_id, brand }) => ({
        old_pk: parseInt(id),
        old_buyer_id: parseInt(buyer_id),
        brand
    }));

    const values = data.map(bb => [
        bb.old_buyer_id,
        bb.brand,
        bb.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_brands (
                old_buyer_id, brand, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_brand - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_id in buyer_brands...`);
    await pgPool.query(`UPDATE buyer_brands bb
        SET buyer_id = b.id
        FROM buyers b
        WHERE bb.old_buyer_id = b.old_pk;
    `);

    // await pgPool.query(`DELETE FROM buyer_brands WHERE buyer_id IS NULL;`);

    console.log(`Completed transferring buyer_brands.`);
}
