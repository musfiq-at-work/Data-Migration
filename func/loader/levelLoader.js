import fs from "fs";
import pkg from "pg-copy-streams";
const copyFrom = pkg.from;

async function loadLevels(pgPool) {
  console.log("Starting COPY import for levels...");

  const client = await pgPool.connect(); // 🔥 MUST use a client

  try {
    const copySql = `
      COPY public.levels (id, name) FROM stdin
    `;

    // 🔥 client.query returns a COPY stream — pgPool.query does NOT
    const pgStream = client.query(copyFrom(copySql));

    const fileStream = fs.createReadStream("./func/loader/sql/level.sql");

    await new Promise((resolve, reject) => {
      fileStream
        .pipe(pgStream)
        .on("finish", resolve)
        .on("error", reject);
    });

    console.log("levels import complete");
  } catch (err) {
    console.error("levels import failed:", err);
  } finally {
    client.release(); // 🔥 don't forget
  }
}

export default loadLevels;
