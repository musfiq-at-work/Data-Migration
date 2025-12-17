import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerPaymentTerms = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_payment_terms...`);
    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyers`);

    if (!rows.length) {
        console.log(`No data in buyers to transfer buyer_payment_terms.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyers for buyer_payment_terms.`);
    }

    let data = rows.map(({id, payment_term }) => ({
        old_buyer_id: parseInt(id),
        old_payment_term_id: payment_term,
    }));

    const terms = [];
    data.forEach(bpt => {
        if (bpt.old_payment_term_id) {
            const termIds = bpt.old_payment_term_id.split(',').map(id => parseInt(id.trim()));
            termIds.forEach(termId => {
                terms.push({
                    old_buyer_id: bpt.old_buyer_id,
                    old_payment_term_id: termId,
                });
            });
        }
    })
    
    const values = terms.map(bpt => [
        bpt.old_buyer_id,
        bpt.old_payment_term_id
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(values.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_payment_term (
                old_buyers_id, old_payment_term_id
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_payment_terms - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating buyer_id and payment_term_id in buyer_payment_terms...`);
    await pgPool.query(`UPDATE buyer_payment_term bpt
        SET buyer_id = b.id
        FROM buyers b
        WHERE bpt.old_buyers_id = b.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_payment_term bpt
        SET payment_term_id = pt.id
        FROM payment_terms pt
        WHERE bpt.old_payment_term_id = pt.old_pk;`
    );

    await pgPool.query(`DELETE FROM buyer_payment_term
        WHERE buyer_id IS NULL OR payment_term_id IS NULL;`
    );

    console.log(`Completed transferring buyer_payment_terms.`);
}