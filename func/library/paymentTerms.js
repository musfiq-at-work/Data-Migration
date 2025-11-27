import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const paymentTerms = async (mysqlConn, pgPool) => {
    console.log(`Transferring payment terms...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM payment_terms`);

    if (!rows.length) {
        console.log(`No data in payment_terms to transfer.`);
        return;
    }

    console.log(`Fetched ${rows.length} rows from payment_terms.`);

    let data = rows.map(({id, term_name, lead_time, term_details}) => ({
        term_id: term_name === 'TT' ? 1 : 2,
        tenor: lead_time ?? 0,
        term_description: term_details,
        old_pk: id
    }));

    const values = data.map(o => [
        o.term_id,
        o.tenor,
        o.term_description,
        o.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO payment_terms (
                term_id, tenor, term_description, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into payment_terms.`);
        epoch++;
    }
    console.log(`Completed transferring payment terms.`);
}