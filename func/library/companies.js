import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const companies = async (mysqlConn, pgPool) => {
    console.log(`Transferring companies...`);
    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM companies`);
    if (!rows.length) {
        console.log(`No data in companies to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from companies.`);
    }

    let data = rows.map(({id, company_name, street, city, zip_code, phone_no, email_address}) => ({
        old_pk: id,
        name: company_name,
        street,
        city,
        zip_code,
        phone_no,
        email: email_address,
    }));

    const values = data.map(c => [
        c.name,
        c.street,
        c.city,
        c.zip_code,
        c.phone_no,
        c.email,
        c.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO companies (
                name, street, city, zip_code, phone_no, email, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into companies.`);
        epoch++;
    }
    console.log(`Completed transferring companies.`);
}