import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const factoryBanks = async (mysqlConn, pgPool) => {
    console.log(`Transferring factory_banks...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM supplier_banks`);

    if (!rows.length) {
        console.log(`No data in supplier_banks to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from supplier_banks.`);
    }

    let data = rows.map(({id,  factory_id, bank_id,  branch_name, ac_name, ac_no, address, swift }) => ({
        old_pk: parseInt(id),
        old_factory_id: parseInt(factory_id),
        old_bank_id: parseInt(bank_id),
        branch_name,
        account_name: ac_name,
        account_no: ac_no,
        address,
        swift_code: swift,
    }));

    const values = data.map(fb => [
        fb.old_factory_id,
        fb.old_bank_id,
        fb.branch_name,
        fb.account_name,
        fb.account_no,
        fb.address,
        fb.swift_code,
        fb.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO factory_bank (
                old_factory_id, old_bank_id, branch_name, account_name, account_no, address, swift_code, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into factory_bank - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating factory_id and bank_id in factory_bank...`);
    await pgPool.query(`UPDATE factory_bank fb
        SET factory_id = f.id
        FROM factories f
        WHERE fb.old_factory_id = f.old_pk;`
    );

    await pgPool.query(`UPDATE factory_bank fb
        SET bank_id = b.id
        FROM banks b
        WHERE fb.old_bank_id = b.old_pk;`
    );

    await pgPool.query(`DELETE FROM factory_bank WHERE factory_id IS NULL OR bank_id IS NULL;`);

    console.log(`Completed transferring factory_bank.`);
}
