import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerAdditionalClause = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_additional_clauses...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_additional_clauses`);

    if (!rows.length) {
        console.log(`No data in buyer_additional_clauses to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_additional_clauses.`);
    }

    let data = rows.map(({id, buyer_id, slno, description }) => ({
        old_pk: parseInt(id),
        old_buyer_id: parseInt(buyer_id),
        sl_no: parseInt(slno),
        description,
    }));

    const values = data.map(bac => [
        bac.old_buyer_id,
        bac.sl_no,
        bac.description,
        bac.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_additional_clause (
                old_buyers_id, sl_no, description, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_additional_clauses - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating buyer_id in buyer_additional_clauses...`);
    await pgPool.query(`UPDATE buyer_additional_clause bac
        SET buyer_id = b.id
        FROM buyers b
        WHERE bac.old_buyers_id = b.old_pk;
    `);

    console.log(`Completed transferring buyer_additional_clauses.`);
}