import pandas as pd
import sqlite3
from pathlib import Path

# Project paths
BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
DB_PATH = BASE_DIR / "sql" / "project.db"

# Connect to SQLite database
conn = sqlite3.connect(DB_PATH)

# Find every CSV file in data/
for csv_file in DATA_DIR.glob("*.csv"):

    # Use filename as table name
    table_name = csv_file.stem

    print(f"Loading {csv_file.name} -> {table_name}")

    # Read CSV
    df = pd.read_csv(csv_file)

    # Save into SQLite
    df.to_sql(
        table_name,
        conn,
        if_exists="replace",
        index=False
    )

    print(f"Loaded {len(df)} rows")

conn.close()

print("All CSV files loaded successfully.")