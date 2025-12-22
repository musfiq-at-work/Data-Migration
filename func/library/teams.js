import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const teams = async (mysqlConn, pgPool) => {
    console.log(`Transferring teams...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM teams`);

    if (!rows.length) {
        console.log(`No data in teams to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from teams.`);
    }

    let data = rows.map(({id, team_name, buyer_id}) => ({
        old_pk: parseInt(id),
        team_name,
        old_buyer_id: parseInt(buyer_id)
    }));

    const values = data.map(team => [
        team.team_name,
        team.old_buyer_id,
        team.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO teams (
                team_name, old_buyer_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into teams - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating buyer_id in teams...`);
    await pgPool.query(`UPDATE teams t
        SET buyer_id = b.id
        FROM buyers b
        WHERE t.old_buyer_id = b.old_pk;
    `);

    // await pgPool.query(`DELETE FROM teams WHERE buyer_id IS NULL;`);

    console.log(`Completed transferring teams.`);
}

