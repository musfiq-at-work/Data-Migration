import format from "pg-format";
import { chunkArray } from "../../helper/chunk.js";
import { deptMap, levelMap, activeStatusMap } from "../../helper/map.js";

export const transferUsers = async (mysqlConn, pgPool) =>{
    console.log(`Transferring users...`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM app_users`);
    if (!rows.length) {
        console.log(`No data in app_users to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from app_users.`);
    }

    let data = rows.map(({ id, first_name, last_name, phone_no, email, user_password, user_for, user_status, password, user_level_id, user_id }) => ({
        old_pk: id,
        first_name,
        last_name,
        phone_no,
        email,
        user_id,
        password: user_password,
        hashed_password: password,
        level_id: levelMap[user_level_id] ?? null,
        department_id: deptMap[user_for] ?? null,
        isActive: activeStatusMap[user_status] ?? null,
        created_at: new Date()
    }));

    const values = data.map(u => [
        u.old_pk,
        u.first_name,
        u.last_name,
        u.phone_no,
        u.email,
        u.user_id,
        u.password,
        u.hashed_password,
        u.level_id,
        u.department_id,
        u.isActive,
        u.created_at,
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time

    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    const deletedUsers = await pgPool.query(`DELETE FROM users`);
    console.log(`Deleted ${deletedUsers.rowCount} existing users in Postgres before transfer.`);

    for (const batch of batches) {
        const query = format(
            `INSERT INTO users (
                old_pk, first_name, last_name, phone_no, email, user_id, password,
                hashed_password, level_id, department_id, is_active, created_at
            ) VALUES %L`,
            batch
        );

        await pgPool.query(query);

        epoch++;

        console.log(`Users Batch: ${epoch} / ${totalBatch}`);
    }

    console.log(`User transfer completed. Total ${data.length} users transferred.`);
}
