import os
import logging
import sys
from datetime import datetime
from dotenv import load_dotenv
import psycopg2

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMA_PATH = os.path.join(ROOT_DIR, "Data Warehouse", "src", "dw_schema.sql")

'''
Konfigurasi Logger
'''
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(ROOT_DIR, "Data Warehouse", "warehouse_log.txt"), encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

'''
Load env variables dari file .env
'''
load_dotenv(os.path.join(ROOT_DIR, ".env"))

# Environment Database OLTP (KPOP DB)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "kpopdb")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASSWORD")

# Environment Data Warehouse (KPOP DW)
DW_HOST = os.getenv("DW_HOST", "localhost")
DW_PORT = os.getenv("DW_PORT", "5432")
DW_NAME = os.getenv("DW_NAME", "kpopdw")
DW_USER = os.getenv("DW_USER", "postgres")
DW_PASS = os.getenv("DW_PASSWORD")

'''
Fungsi untuk inisialisasi koneksi Database OLTP (kpopdb)
'''
def init_db_oltp():
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    conn.autocommit = True
    return conn

'''
Fungsi untuk inisialisasi koneksi database Data Warehouse (kpopdw)
'''
def init_db_dw():
    conn = psycopg2.connect(
        host=DW_HOST,
        port=DW_PORT,
        database=DW_NAME,
        user=DW_USER,
        password=DW_PASS
    )
    conn.autocommit = True
    return conn

'''
Fungsi untuk membuat skema Data Warehouse
'''
def create_schema(conn_dw):
    cursor = conn_dw.cursor()
    logging.info(f"Membuat skema berdasarkan script di '{SCHEMA_PATH}'")
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        sql_schema = f.read()

    cursor.execute(sql_schema)
    logging.info("Berhasil membuat skema Data Warehouse")
    return conn_dw

'''
Helper mendaftarkan tanggal ke dim_time
'''
def register_date(cursor_dw, date_input):
    # Jika berupa objek datetime/date
    if hasattr(date_input, 'strftime'):
        dt = date_input
    else:
        # Jika berupa string YYYY-MM-DD HH:MM:SS
        dt = datetime.strptime(str(date_input).split(" ")[0], "%Y-%m-%d")

    id_time = int(dt.strftime("%Y%m%d"))
    full_date = dt.strftime("%Y-%m-%d")
    year = dt.year
    quarter = (dt.month - 1) // 3 + 1
    month = dt.month
    day = dt.day

    cursor_dw.execute(
        """
        INSERT INTO dim_time (id_time, full_date, year, quarter, month, day)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (id_time) DO NOTHING
        """,
        (id_time, full_date, year, quarter, month, day)
    )

    return id_time

'''
Fungsi untuk migrasi data dari OLTP ke Data Warehouse
'''
def migrate_data(conn_oltp, conn_dw):
    cursor_oltp = conn_oltp.cursor()
    cursor_dw = conn_dw.cursor()

    # Ekstrak & Insert dari labels OLTP ke dim_label DWH
    logging.info("Memulai ekstraksi dari labels OLTP ke dim_label OLAP")
    cursor_oltp.execute("SELECT id_label, name, founded_year, founder FROM labels;")
    labels = cursor_oltp.fetchall()
    for row in labels:
        id_label, name, founded_year, founder = row
        cursor_dw.execute(
            """
            INSERT INTO dim_label(id_label, name, founded_year, founder)
            VALUES(%s, %s, %s, %s)
            ON CONFLICT (id_label) DO UPDATE
            SET name = EXCLUDED.name,
                founded_year = EXCLUDED.founded_year,
                founder = EXCLUDED.founder
            """,
            (id_label, name, founded_year, founder)
        )
    logging.info(f"Berhasil migrasi data dim_label")

    # Ekstrak & Insert dari groups OLTP ke dim_group DWH
    logging.info("Memulai ekstraksi data groups OLTP ke dim_group OLAP")
    cursor_oltp.execute("SELECT id_group, name, other_name, status, debut_date, id_label, id_parent_group FROM groups;")
    groups = cursor_oltp.fetchall()
    # Simpan mapping: id_group -> id_label (untuk mengisi fact_group_metrics nanti)
    group_to_label = {}

    for row in groups:
        id_group, name, other_name, status, debut_date, id_label, id_parent_group = row
        is_subunit = True if id_parent_group is not None else False
        group_to_label[id_group] = id_label

        cursor_dw.execute(
            """
            INSERT INTO dim_group(id_group, group_name, other_name, status, debut_date, is_sub_unit)
            VALUES(%s, %s, %s, %s, %s, %s)
            ON CONFLICT (id_group) DO UPDATE
            SET group_name = EXCLUDED.group_name,
                other_name = EXCLUDED.other_name,
                status = EXCLUDED.status,
                debut_date = EXCLUDED.debut_date,
                is_sub_unit = EXCLUDED.is_sub_unit
            """,
            (id_group, name, other_name, status, debut_date, is_subunit)
        )
    logging.info(f"Berhasil migrasi data dim_group")

    # Ekstrak & Insert dari fandoms OLTP ke dim_fandom DWH
    logging.info("Memulai ekstraksi data fandoms OLTP ke dim_fandom OLAP")
    cursor_oltp.execute("SELECT id_fandom, id_group, name FROM fandoms;")
    fandoms = cursor_oltp.fetchall()
    # Simpan mapping: id_group -> id_fandom (untuk mengisi fact_group_metrics nanti)
    group_to_fandom = {}

    for row in fandoms:
        id_fandom, id_group, fandom_name = row
        group_to_fandom[id_group] = id_fandom

        cursor_dw.execute(
            """
            INSERT INTO dim_fandom(id_fandom, fandom_name)
            VALUES(%s, %s)
            ON CONFLICT (id_fandom) DO UPDATE
            SET fandom_name = EXCLUDED.fandom_name
            """,
            (id_fandom, fandom_name)
        )
    logging.info(f"Berhasil migrasi data dim_fandom")

    # Ekstrak & Insert data group_metrics dari OLTP ke fact_group_metrics DWH
    logging.info("Memulai ekstraksi dari group_metrics OLTP ke fact_group_metrics OLAP")
    cursor_oltp.execute("""
        SELECT id_group, scraped_at, rank, total_bias_votes, dance_score, vocal_score, stage_score, artistry_score, visual_score 
        FROM group_metrics;
    """)
    metrics = cursor_oltp.fetchall()
    for row in metrics:
        id_group, scraped_at, rank, total_bias_votes, dance_score, vocal_score, stage_score, artistry_score, visual_score = row

        id_label  = group_to_label.get(id_group)
        id_fandom = group_to_fandom.get(id_group)
        id_time   = register_date(cursor_dw, scraped_at)

        # Hitung total_score (rata-rata skor kemampuan valid)
        scores = [dance_score, vocal_score, stage_score, artistry_score, visual_score]
        valid_scores = [float(s) for s in scores if s is not None]
        total_score = round(sum(valid_scores) / len(valid_scores), 2) if valid_scores else None

        cursor_dw.execute(
            """
            INSERT INTO fact_group_metrics(
                id_time, id_group, id_label, id_fandom, rank, total_bias_votes,
                dance_score, vocal_score, stage_score, artistry_score, visual_score, total_score, scraped_at
            )
            VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id_group, id_time) DO UPDATE
            SET rank = EXCLUDED.rank,
                total_bias_votes = EXCLUDED.total_bias_votes,
                dance_score = EXCLUDED.dance_score,
                vocal_score = EXCLUDED.vocal_score,
                stage_score = EXCLUDED.stage_score,
                artistry_score = EXCLUDED.artistry_score,
                visual_score = EXCLUDED.visual_score,
                total_score = EXCLUDED.total_score,
                scraped_at = EXCLUDED.scraped_at
            """,
            (
                id_time, id_group, id_label, id_fandom, rank, total_bias_votes,
                dance_score, vocal_score, stage_score, artistry_score, visual_score, total_score, scraped_at
            )
        )
    logging.info(f"Berhasil migrasi {len(metrics)} data fact_group_metrics")
    logging.info("Berhasil migrasi semua data dari OLTP ke Data Warehouse")


def store_dw():
    logging.info("Memulai proses ETL migrasi dari DB OLTP (kpopdb) ke DB DWH (kpopdw)")

    logging.info("Menghubungkan koneksi ke database OLTP dan Data Warehouse")
    conn_oltp = init_db_oltp()
    conn_dw = init_db_dw()

    create_schema(conn_dw)
    migrate_data(conn_oltp, conn_dw)

    conn_oltp.close()
    conn_dw.close()
    logging.info("Menutup seluruh koneksi database")

if __name__ == "__main__":
    store_dw()
