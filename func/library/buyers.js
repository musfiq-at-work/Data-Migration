import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyers = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyers...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyers`);

    if (!rows.length) {
        console.log(`No data in buyers to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyers.`);
    }

    let data = rows.map(({id, buyer_name, short_name, prefix, address, contact_person, phone_no, email_address, website, overseas_office_id }) => ({
        old_pk: parseInt(id),
        buyer_name,
        short_name,
        prefix,
        address,
        contact_person,
        phone_no,
        email: email_address,
        website,
        old_overseas_office_id: overseas_office_id ? parseInt(overseas_office_id) : null,
    }));

    const values = data.map(buyer => [
        buyer.buyer_name,
        buyer.short_name,
        buyer.prefix,
        buyer.address,
        buyer.contact_person,
        buyer.phone_no,
        buyer.email,
        buyer.website,
        buyer.old_overseas_office_id,
        buyer.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyers (
                buyer_name, short_name, prefix, address, contact_person, phone_no, email, website, old_overseas_office_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyers - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating overseas_office_id in buyers...`);
    await pgPool.query(`UPDATE buyers b
        SET overseas_office_id = oo.id
        FROM overseas_offices oo
        WHERE b.old_overseas_office_id = oo.old_pk;`
    );

    console.log(`Buyers transfer completed.`);
};