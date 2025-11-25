import format from "pg-format";
import { chunkArray } from "../../helper/chunk.js";
import { levelMap, moduleMap } from "../../helper/map.js";

export const levelPermissions = async (mysqlConn, pgPool) =>{
    console.log(`Transferring level Permissions...`);

    // Clean up orphaned records in MySQL
    const resMySQL = await mysqlConn.query(`delete from level_privileges where menu_id not in (
        select id from app_menus
    )`)

    console.log(`Deleted ${resMySQL[0].affectedRows} orphaned level_privileges records.`);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM level_privileges`);
    if (!rows.length) {
        console.log(`No data in level_privileges to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from level_privileges.`);
    }

    let data = rows.map(({ id, user_level_id, menu_id, rec_create, rec_read, rec_update, rec_delete }) => ({
        old_pk: id,
        level_id: levelMap[user_level_id] ?? null,
        module_id: moduleMap[menu_id] ?? 64,
        can_add: rec_create,
        can_view: rec_read,
        can_update:rec_update,
        can_delete: rec_delete
    }));

    const values = data.map(u => [
        u.old_pk,
        u.level_id,
        u.module_id,
        u.can_add,
        u.can_view,
        u.can_update,
        u.can_delete,
    ]);

    const deletedPermissions = await pgPool.query(`DELETE FROM level_permission`);
    console.log(`Deleted ${deletedPermissions.rowCount} existing level_permission records in Postgres before transfer.`);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100); // 100 at a time

    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO level_permission (
                old_pk, level_id, module_id, can_add, can_view, can_update, can_delete
            ) VALUES %L`,
            batch
        );

        await pgPool.query(query);
        // console.log(query); // For testing, log the query instead of executing
        epoch++;

        console.log(`Level Permissions Batch: ${epoch} / ${totalBatch}`);
    }

    // Remove existing permissions for module_id = 64, these modules do not exist in new system
    const resPg = await pgPool.query(`delete from level_permission where module_id = 64`);

    console.log(`Deleted ${resPg.rowCount} level_permission records where modules do not exist in new system.`);

    console.log(`Permissions transfer completed. Total ${data.length} permissions transferred.`);
}
