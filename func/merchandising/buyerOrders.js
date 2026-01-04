import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const buyerOrders = async (mysqlConn, pgPool) => {
    console.log(`Transferring buyer_orders...`);

    // Clean up specific problematic records in MySQL before transfer
    // await mysqlConn.query(`
    //     delete from orders where id in (1, 4, 9, 21, 22, 23, 30, 37, 39, 40, 2179, 2180);
    // `);

    // Fetch from MySQL
    const [rows] = await mysqlConn.query(`SELECT * FROM orders`);

    if (!rows.length) {
        console.log(`No data in orders to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from orders.`);
    }

    let data = rows.map(({
        id, 
        dm_order_no,
        buyer_id,
        season_id,
        fob_type_id,
        order_date,
        team_id,
        buyer_brand_id,
        buyer_department_id,
        currency_id_2,
        currency_rate,
        factory_id,
    }) => ({
        old_pk: parseInt(id),
        REF_NO: dm_order_no,
        OLD_BUYER_ID: parseInt(buyer_id),
        OLD_SEASON_ID: parseInt(season_id),
        OLD_FOB_TYPE: parseInt(fob_type_id),
        ORDER_DATE: order_date,
        OLD_TEAM_ID: parseInt(team_id),
        OLD_BRAND_ID: parseInt(buyer_brand_id),
        OLD_DEPARTMENT_ID: parseInt(buyer_department_id),
        OLD_SECONDARY_CURRENCY_ID: parseInt(currency_id_2),
        CURRENCY_RATE: currency_rate,
        OLD_FACTORY_ID: parseInt(factory_id),
    }));

    const values = data.map(bo => [
        bo.REF_NO,
        bo.OLD_BUYER_ID,
        bo.OLD_SEASON_ID,
        bo.OLD_FOB_TYPE,
        bo.ORDER_DATE,
        bo.OLD_TEAM_ID,
        bo.OLD_BRAND_ID,
        bo.OLD_DEPARTMENT_ID,
        bo.OLD_SECONDARY_CURRENCY_ID,
        bo.CURRENCY_RATE,
        bo.OLD_FACTORY_ID,
        bo.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    for (const batch of batches) {
        const query = format(
            `INSERT INTO buyer_orders (
                ref_no, old_buyer_id, old_season_id, old_fob_type, order_date, old_team_id, old_brand_id, old_department_id, old_secondary_currency_id, currency_rate, old_factory_id, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into buyer_orders - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    };

    console.log(`Updating foreign keys in buyer_orders...`);
    await pgPool.query(`UPDATE buyer_orders bo
        SET buyer_id = b.id
        FROM buyers b
        WHERE bo.old_buyer_id = b.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET season_id = s.id
        FROM seasons s
        WHERE bo.old_season_id = s.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET FOB_TYPE_ID = ft.id
        FROM fob_types ft
        WHERE bo.old_fob_type = ft.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET team_id = t.id
        FROM teams t
        WHERE bo.old_team_id = t.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET brand_id = bb.id
        FROM buyer_brands bb
        WHERE bo.old_brand_id = bb.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET department_id = bd.id
        FROM buyer_departments bd
        WHERE bo.old_department_id = bd.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET secondary_currency_id = c.id
        FROM currencies c
        WHERE bo.old_secondary_currency_id = c.old_pk;`
    );

    await pgPool.query(`UPDATE buyer_orders bo
        SET factory_id = f.id
        FROM factories f
        WHERE bo.old_factory_id = f.old_pk;`
    );

    console.log(`Cleaning up buyer_orders with missing foreign keys...`);

    await pgPool.query(`DELETE FROM BUYER_ORDERS WHERE BUYER_ID IS NULL OR TEAM_ID IS NULL;`);

    console.log(`Completed transferring buyer_orders.`);
};
