import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const couriers = async (mysqlConn, pgPool) => {
    console.log(`Transferring couriers...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM couriers`);

    if (!rows.length) {
        console.log(`No data in couriers to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from couriers.`);
    }

    let data = rows.map(({id, courier_name, contact_person, phone_no, email_address, address, website}) => ({
        old_pk: parseInt(id),
        name: courier_name,
        contact_person,
        email: email_address,
        phone_no,
        address,
        website,
    }));

    const values = data.map(c => [
        c.name,
        c.contact_person,
        c.email,
        c.phone_no,
        c.address,
        c.website,
        c.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO couriers (
                name, contact_person, email, phone_no, address, website, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into couriers - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }
    
    console.log(`Completed transferring couriers.`);
}