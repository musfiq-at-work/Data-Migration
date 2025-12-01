import fs from "fs";
import pkg from "pg-copy-streams";
const copyFrom = pkg.from;

async function loadModules(pgPool) {
  console.log("Starting COPY import for modules...");

  const client = await pgPool.connect(); // 🔥 MUST use a client

  try {
    const copySql = `
      COPY public.modules (id, name, parent_module_id) FROM stdin
    `;

    // 🔥 client.query returns a COPY stream — pgPool.query does NOT
    const pgStream = client.query(copyFrom(copySql));

    const fileStream = fs.createReadStream("./func/loader/sql/modules.sql");

    await new Promise((resolve, reject) => {
      fileStream
        .pipe(pgStream)
        .on("finish", resolve)
        .on("error", reject);
    });

    console.log("modules import complete");
  } catch (err) {
    console.error("modules import failed:", err);
  } finally {
    client.release(); // 🔥 don't forget
  }
}

export default loadModules;
