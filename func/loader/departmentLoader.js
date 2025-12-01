import fs from "fs";
import pkg from "pg-copy-streams";
const copyFrom = pkg.from;

async function loadDepartments(pgPool) {
  console.log("Starting COPY import for departments...");

  const client = await pgPool.connect(); // 🔥 MUST use a client

  try {
    const copySql = `
      COPY public.departments (id, name) FROM stdin
    `;

    // 🔥 client.query returns a COPY stream — pgPool.query does NOT
    const pgStream = client.query(copyFrom(copySql));

    const fileStream = fs.createReadStream("./func/loader/sql/departments.sql");

    await new Promise((resolve, reject) => {
      fileStream
        .pipe(pgStream)
        .on("finish", resolve)
        .on("error", reject);
    });

    console.log("departments import complete");
  } catch (err) {
    console.error("departments import failed:", err);
  } finally {
    client.release(); // 🔥 don't forget
  }
}

export default loadDepartments;
