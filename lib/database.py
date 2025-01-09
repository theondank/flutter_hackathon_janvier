import sqlite3

def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(f"Connected to SQLite database: {db_file}")
    except sqlite3.Error as e:
        print(e)
    return conn

def create_table(conn):
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deputy_id TEXT NOT NULL,
        entry_time TEXT NOT NULL
    );
    """
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
    except sqlite3.Error as e:
        print(e)

def insert_entry(conn, deputy_id):
    sql = '''INSERT INTO entries(deputy_id, entry_time)
             VALUES(?, datetime('now'))'''
    cur = conn.cursor()
    cur.execute(sql, (deputy_id,))
    conn.commit()
    return cur.lastrowid

def main():
    database = "deputies_entries.db"
    conn = create_connection(database)
    if conn is not None:
        create_table(conn)
    else:
        print("Error! Cannot create the database connection.")

if __name__ == '__main__':
    main()