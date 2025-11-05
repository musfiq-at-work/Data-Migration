// --- API endpoint ---
// app.post("/transfer", async (req, res) => {
//   const { tables } = req.body; // e.g. { "tables": ["users", "orders"] }

//   if (!tables?.length) {
//     return res.status(400).json({ error: "No tables specified" });
//   }

//   for (const table of tables) {
//     await transferTable(table);
//   }

//   res.json({ message: "Data transfer complete!" });
// });

// --- Start Server ---
// app.listen(5000, () => console.log("🚀 Server running on http://localhost:5000"));
