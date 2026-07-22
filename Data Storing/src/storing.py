import os
import json
import logging
import sys
from dotenv import load_dotenv
import psycopg2

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMA_PATH = os.path.join(ROOT_DIR, "Data Storing", "src", "schema.sql")

'''
Konfigurasi Logger
'''
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(ROOT_DIR, "Data Storing", "storing_log.txt"), encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

'''
Load env variables dari file .env
'''
load_dotenv(os.path.join(ROOT_DIR, ".env"))
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASSWORD")

'''
Helper load file json
'''
def load_json(clean_dir, filename):
    path = os.path.join(clean_dir, filename)   
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

'''
Fungsi untuk inisialisasi koneksi database
'''
def init_db():
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
Fungsi untuk membuat skema
'''
def create_schema(conn):
    cursor = conn.cursor()
    logging.info(f"Membuat skema berdasarkan script di '{SCHEMA_PATH}'")
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        sql_schema = f.read()

    cursor.execute(sql_schema)
    logging.info("Berhasil membuat skema")
    return conn

'''
Fungsi untuk menginsert data
'''
def insert_data(conn, clean_dir):
    cursor = conn.cursor()

    # Insert data labels
    labels = load_json(clean_dir, "labels.json")
    logging.info(f"Memulai insert data labels")
    for i in labels:
        cursor.execute(
            """
            INSERT INTO labels(ID_label, name, founded_year, founder)
            VALUES(%s, %s, %s, %s)
            ON CONFLICT (ID_label) DO NOTHING
            """,
            (i["id_label"], i["name"], i["founded_year"], i["founder"])
        )
    logging.info("Berhasil insert data labels")

    # Insert data idols
    idols = load_json(clean_dir, "idols.json")
    logging.info(f"Memulai insert data idols")
    for i in idols:
        cursor.execute(
            """
            INSERT INTO idols(ID_idol, stage_name, full_name, birthday, birth_adm_area, birth_country, height)
            VALUES(%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (ID_idol) DO NOTHING
            """,
            (i["id_idol"], i["stage_name"], i["full_name"], i["birthday"], i["birth_adm_area"], i["birth_country"], i["height"])
        )
    logging.info("Berhasil insert data idols")

    # Insert data groups (Fase 1: Insert semua grup tanpa ID_parent_group untuk menghindari FK violation)
    groups = load_json(clean_dir, "groups.json")
    logging.info(f"Memulai insert data groups (Fase 1: Data detail)")
    for i in groups:
        cursor.execute(
            """
            INSERT INTO groups(ID_group, ID_label, name, other_name, status, debut_date)
            VALUES(%s, %s, %s, %s, %s, %s)
            ON CONFLICT (ID_group) DO NOTHING
            """,
            (i["id_group"], i["id_label"], i["name"], i["other_name"], i["status"], i["debut_date"])
        )
    # Insert data groups (Fase 2: Hubungkan ID_parent_group setelah seluruh grup diinsert)
    logging.info("Memulai insert data groups (Fase 2: Hubungkan ID_parent)")
    for i in groups:
        if i.get("id_parent_group") is not None:
            cursor.execute(
                """
                UPDATE groups 
                SET ID_parent_group = %s 
                WHERE ID_group = %s
                """,
                (i["id_parent_group"], i["id_group"])
            )
    logging.info("Berhasil insert data groups")

    # Insert data disbanded groups
    disbanded = load_json(clean_dir, "group_disbanded.json")
    logging.info(f"Memulai insert data disbanded groups")
    for i in disbanded:
        cursor.execute(
            """
            INSERT INTO disbanded_groups(ID_group, disband_year)
            VALUES(%s, %s)
            ON CONFLICT (ID_group) DO UPDATE
            SET disband_year = EXCLUDED.disband_year
            """,
            (i["id_group"], i["disband_year"])
        )
    logging.info("Berhasil insert data disbanded groups")

    # Insert data hiatus groups
    hiatus = load_json(clean_dir, "group_hiatus.json")
    logging.info(f"Memulai insert data hiatus groups")
    for i in hiatus:
        cursor.execute(
            """
            INSERT INTO hiatus_groups (ID_group, hiatus_year)
            VALUES (%s, %s)
            ON CONFLICT (ID_group) DO UPDATE
            SET hiatus_year = EXCLUDED.hiatus_year
            """,
            (i["id_group"], i["hiatus_year"])
        )
    logging.info("Berhasil insert data hiatus groups")

    # Insert data group idols
    group_idols = load_json(clean_dir, "group_idols.json")
    logging.info(f"Memulai insert data group members")
    for i in group_idols:
        cursor.execute(
            """
            INSERT INTO group_idols(ID_group, ID_idol, role)
            VALUES(%s, %s, %s)
            ON CONFLICT DO NOTHING
            """,
            (i["id_group"], i["id_idol"], i["role"])
        )
    logging.info("Berhasil insert data group members")

    # Insert data group metrics
    group_metrics = load_json(clean_dir, "group_metrics.json")
    logging.info(f"Memulai insert data group metrics")
    for i in group_metrics:
        cursor.execute(
            """
            INSERT INTO group_metrics(ID_group, scraped_at, rank, total_bias_votes, dance_score, vocal_score, stage_score, artistry_score, visual_score)
            VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (ID_group, scraped_at) DO NOTHING
            """,
            (i["id_group"], i["scraped_at"], i["rank"], i["total_bias_votes"], i["dance_score"], i["vocal_score"], i["stage_score"], i["artistry_score"], i["visual_score"])
        )
    logging.info("Berhasil insert data group metrics")

    # Insert data albums
    albums = load_json(clean_dir, "albums.json")
    logging.info(f"Memulai insert data albums")
    for i in albums:
        cursor.execute(
            """
            INSERT INTO albums(ID_album, ID_group, name, type, release_date, language, description)
            VALUES(%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (ID_album) DO NOTHING
            """,
            (i["id_album"],  i["id_group"], i["name"], i["type"], i["release_date"], i["language"], i["description"])
        )
    logging.info("Berhasil insert data albums")

    # Insert data tracks
    tracks = load_json(clean_dir, "album_tracks.json")
    logging.info(f"Memulai insert data tracks")
    for i in tracks:
        cursor.execute(
            """
            INSERT INTO tracks(ID_album, title)
            VALUES(%s, %s)
            ON CONFLICT DO NOTHING
            """,
            (i["id_album"], i["track"])
        )
    logging.info("Berhasil insert data tracks")

    # Insert data fandoms
    fandoms = load_json(clean_dir, "fandoms.json")
    logging.info(f"Memulai insert data fandoms")
    for i in fandoms:
        cursor.execute(
            """
            INSERT INTO fandoms(ID_fandom, ID_group, name)
            VALUES(%s, %s, %s)
            ON CONFLICT (ID_fandom) DO NOTHING
            """,
            (i["id_fandom"], i["id_group"], i["fandom_name"])
        )
    logging.info("Berhasil insert data fandoms")

    fandom_colors = load_json(clean_dir, "fandom_colors.json")
    logging.info(f"Memulai insert data fandom colors")
    for i in fandom_colors:
        cursor.execute(
            """
            INSERT INTO fandom_colors (ID_fandom, color_identity)
            VALUES (%s, %s)
            ON CONFLICT DO NOTHING
            """,
            (i["id_fandom"], i["color_identity"])
        )
    logging.info("Berhasil insert data fandom colors")
    logging.info("Berhasil insert semua data ke database")

def store(batch_name):
    clean_dir = os.path.join(ROOT_DIR, "Data Scraping", "data", batch_name, "clean")
    logging.info(f"Memulai storing data bersih dari batch '{batch_name}'")

    logging.info(f"Menghubungkan koneksi database")
    conn = init_db()
    create_schema(conn)
    insert_data(conn, clean_dir)

    conn.close()
    logging.info("Menutup koneksi database")

if __name__ == "__main__":
    store("batch-2026-07-20")
