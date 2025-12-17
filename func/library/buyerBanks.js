import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerBanks = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_banks...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM buyer_banks`);

    if (!rows.length) {
        console.log(`No data in buyer_bank to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from buyer_bank.`);
    }

    let data = rows.map(({id,  buyer_id, bank_id,  branch_name, ac_name, ac_no, address, swift }) => ({
        old_pk: parseInt(id),
        old_buyer_id: parseInt(buyer_id),
        old_bank_id: parseInt(bank_id),
        branch_name,
        account_name: ac_name,
        account_no: ac_no,
        address,
        swift,
    }));

    const values = data.map(bb => [
        bb.old_buyer_id,
        bb.old_bank_id,
        bb.branch_name,
        bb.account_name,
        bb.account_no,
        bb.address,
        bb.swift,
        bb.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_banks (
                old_buyers_id, old_bank_id, branch_name, account_name, account_no, address, swift, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_bank - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating buyer_id and bank_id in buyer_bank...`);
    await pgPool.query(`UPDATE buyer_banks bb
        SET buyer_id = b.id
        FROM buyers b
        WHERE bb.old_buyers_id = b.old_pk;
    `);

    await pgPool.query(`UPDATE buyer_banks bb
        SET bank_id = ba.id
        FROM banks ba
        WHERE bb.old_bank_id = ba.old_pk;
    `);
};