import fs from "fs";
import pkg from "pg-copy-streams";
const copyFrom = pkg.from;

async function loadAuthorizations(pgPool) {
  console.log("Starting COPY import for authorizations...");

  const client = await pgPool.connect(); // 🔥 MUST use a client

  try {
    const copySql = `
      COPY public.authorizations (
        id, module_id, level_id, is_enabled, name, updated_by, updated_at
      ) FROM STDIN
    `;

    // 🔥 client.query returns a COPY stream — pgPool.query does NOT
    const pgStream = client.query(copyFrom(copySql));

    const fileStream = fs.createReadStream("./func/loader/authorizations.sql");

    await new Promise((resolve, reject) => {
      fileStream
        .pipe(pgStream)
        .on("finish", resolve)
        .on("error", reject);
    });

    console.log("authorizations import complete");
  } catch (err) {
    console.error("authorizations import failed:", err);
  } finally {
    client.release(); // 🔥 don't forget
  }
}

export default loadAuthorizations;
