import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const teamMember = async (mysqlConn, pgPool) => {
    console.log(`Transferring team_members...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM team_members`);

    if (!rows.length) {
        console.log(`No data in team_members to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from team_members.`);
    }

    let data = rows.map(({id, team_id, app_user_id}) => ({
        old_pk: parseInt(id),
        old_team_id: parseInt(team_id),
        old_user_id: parseInt(app_user_id)
    }));

    const values = data.map(tm => [
        tm.old_team_id,
        tm.old_user_id,
        tm.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO team_members (
                old_team_id, old_user_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into team_members - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }   

    console.log(`Updating team_id and app_user_id in team_members...`);
    await pgPool.query(`UPDATE team_members tm
        SET team_id = t.id
        FROM teams t
        WHERE tm.old_team_id = t.old_pk;
    `);

    await pgPool.query(`UPDATE team_members tm
        SET user_id = au.id
        FROM USERS au
        WHERE tm.old_user_id = au.old_pk;
    `);

    await pgPool.query(`DELETE FROM team_members WHERE team_id IS NULL OR user_id IS NULL;`);

    console.log(`Completed transferring team_members.`);
}