import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const factories = async (mysqlConn, pgPool) => {
    console.log(`Transferring factories...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM ex_factories`);

    if (!rows.length) {
        console.log(`No data in factories to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from factories.`);
    }

    let data = rows.map(({
        id, 
        factory_name, 
        short_name, 
        office_address, 
        factory_address, 
        contact_person,
        phone_no,
        email_address,
        website
    }) => ({
        old_pk: id,
        name: factory_name,
        prefix: short_name,
        office_address,
        factory_address,
        contact_person,
        phone_no,
        email: email_address,
        website,
    }));

    const values = data.map(f => [
        f.name,
        f.prefix,
        f.office_address,
        f.factory_address,
        f.contact_person,
        f.phone_no,
        f.email,
        f.website,
        f.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO factories (
                name, prefix, office_address, factory_address, contact_person, phone_no, email, website, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into factories - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring factories.`);
}