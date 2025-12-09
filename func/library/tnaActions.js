import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const tnaActions = async (mysqlConn, pgPool) => {
    console.log(`Transferring TNA Actions...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM tna_actions`);

    if (!rows.length) {
        console.log(`No data in TNA Actions to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from TNA Actions.`);
    }

    let data = rows.map(({id, action_name, lead_time, alert_before, action_for}) => ({
        old_pk: parseInt(id),
        name: action_name,
        lead_time: parseInt(lead_time),
        alert_before: parseInt(alert_before),
        department_id: action_for === 'Merchandising' ? 1 : action_for === 'Commercial' ? 2 : null
    }));

    const values = data.map(t => [
        t.name,
        t.lead_time,
        t.alert_before,
        t.department_id,
        t.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1;

    for (const batch of batches) {
        const query = format(
            `INSERT INTO tna_actions (
                name, lead_time, alert_before, department_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into TNA Actions - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Completed transferring TNA Actions.`);
}
