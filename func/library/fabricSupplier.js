import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const fabricSupplier = async (mysqlConn, pgPool) => {
    console.log(`Transferring fabric_suppliers...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM suppliers`);

    if (!rows.length) {
        console.log(`No data in suppliers to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from suppliers.`);
    }

    let data = rows.map(({id, supplier_name, contact_person, email_address, phone_no, address, website, country}) => ({
        old_pk: parseInt(id),
        name: supplier_name,
        contact_person,
        email: email_address,
        phone_no,
        address,
        website,
    }));

    const values = data.map(s => [
        s.name,
        s.contact_person,
        s.email,
        s.phone_no,
        s.address,
        s.website,
        s.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO fabric_suppliers (
                name, contact_person, email, phone_no, address, website, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into fabric_suppliers.`);
        epoch++;
    }

    console.log(`Completed transferring fabric_suppliers.`);
}
        
