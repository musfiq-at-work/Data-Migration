import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const companyBank = async (mysqlConn, pgPool) => {
    console.log(`Transferring company_banks...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM dm_banks`);

    if (!rows.length) {
        console.log(`No data in dm_banks to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from dm_banks.`);
    }

    let data = rows.map(({id, company_id, bank_id, branch_name, ac_name, ac_no, address, swift }) => ({
        old_pk: parseInt(id),
        old_company_id: company_id,
        old_bank_id: bank_id,
        branch_name,
        account_name: ac_name,
        account_no: ac_no,
        address,
        swift: swift,
    }));

    const values = data.map(cb => [
        cb.old_company_id,
        cb.old_bank_id,
        cb.branch_name,
        cb.account_name,
        cb.account_no,
        cb.address,
        cb.swift,
        cb.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO company_banks (
                old_company_id, old_bank_id, branch_name, account_name, account_no, address, swift, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into company_banks - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }
    console.log(`Updating company_id and bank_id in company_banks...`);
 
    await pgPool.query(`UPDATE company_banks cb
        SET company_id = c.id
        FROM companies c
        WHERE cb.old_company_id = c.old_pk;
    `);
 
    await pgPool.query(`UPDATE company_banks cb
        SET bank_id = b.id
        FROM banks b
        WHERE cb.old_bank_id = b.old_pk;
    `);
 
    await pgPool.query(`DELETE FROM company_banks WHERE company_id IS NULL OR bank_id IS NULL;`);
 
    console.log(`Completed transferring company_banks.`);
}