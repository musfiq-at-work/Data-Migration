import { chunkArray } from "../../helper/chunk.js";
import format from "pg-format";

export const orderDetails = async (mysqlConn, pgPool) => {
    console.log(`Transferring order_details...`);
    // Fetch from MySQL
    // delete problematic records

    console.log('Deleting problematic records from order_details...');
    await mysqlConn.query(`delete from order_details where id in (7213)`);

    const [rows] = await mysqlConn.query(`SELECT * FROM order_details`);

    if (!rows.length) {
        console.log(`No data in order_details to transfer.`);
        return;
    }
    else {
        console.log(`Fetched ${rows.length} rows from order_details.`);
    }

    let data = rows.map(({
        id,
        order_id,
        product_id,
        product_type_id,
        style,
        fabric_id,
        supplier_id,
        order_qty
    }) => ({
        old_pk: parseInt(id),
        OLD_ORDER_ID: parseInt(order_id),
        OLD_PRODUCT_ID: parseInt(product_id),
        OLD_PRODUCT_TYPE_ID: parseInt(product_type_id),
        STYLE: style,
        OLD_FABRIC_ID: parseInt(fabric_id),
        OLD_SUPPLIER_ID: supplier_id ? parseInt(supplier_id) : null,
        ORDER_QTY: order_qty
    }));

    const values = data.map(od => [
        od.OLD_ORDER_ID,
        od.OLD_PRODUCT_ID,
        od.OLD_PRODUCT_TYPE_ID,
        od.STYLE,
        od.OLD_FABRIC_ID,
        od.OLD_SUPPLIER_ID,
        od.ORDER_QTY,
        od.old_pk
    ]);

    // Insert into Postgres in Batches
    const batches = chunkArray(values, 100);
    const totalBatch = Math.ceil(rows.length / 100);
    let epoch = 1

    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN order_id DROP NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN product_id DROP NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN product_type_id DROP NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN fabric_id DROP NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN supplier_id DROP NOT NULL`);
    for (const batch of batches) {
        const query = format(
            `INSERT INTO order_styles (
                old_order_id, old_product_id, old_product_type_id, style, old_fabric_id, old_supplier_id, order_quantity, old_pk
            ) VALUES %L`,
            batch
        );
        await pgPool.query(query);
        console.log(`Inserted batch ${epoch} of ${totalBatch} into order_styles - ${((epoch / totalBatch) * 100).toFixed(2)}%`);
        epoch++;
    }

    console.log(`Updating order_id, product_id, product_type_id, fabric_id, and supplier_id in order_styles...`);
    await pgPool.query(`UPDATE order_styles os
        SET order_id = bo.id
        FROM buyer_orders bo
        WHERE os.old_order_id = bo.old_pk;`
    );

    await pgPool.query(`UPDATE order_styles os
        SET product_id = p.id
        FROM products p
        WHERE os.old_product_id = p.old_pk;`
    );

    await pgPool.query(`UPDATE order_styles os
        SET product_type_id = pt.id
        FROM product_types pt
        WHERE os.old_product_type_id = pt.old_pk;`
    );

    await pgPool.query(`UPDATE order_styles os
        SET fabric_id = f.id
        FROM fabrics f
        WHERE os.old_fabric_id = f.old_pk;`
    );

    await pgPool.query(`UPDATE order_styles os
        SET supplier_id = s.id
        FROM fabric_suppliers s
        WHERE os.old_supplier_id = s.old_pk;`
    );

    console.log(`cleaning up orphaned order_styles records...`);
    await pgPool.query(`DELETE FROM order_styles
        WHERE order_id IS NULL
        OR product_id IS NULL
        OR product_type_id IS NULL
        OR fabric_id IS NULL
        OR supplier_id IS NULL;`
    );

    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN order_id SET NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN product_id SET NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN product_type_id SET NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN fabric_id SET NOT NULL`);
    await pgPool.query(`ALTER TABLE order_styles ALTER COLUMN supplier_id SET NOT NULL`);

    console.log(`Completed transferring order_details.`);

}