import sys
import os
import time
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

'''
Daftarkan lokasi subfolder ke sys.path agar Python dapat menemukan modul dari subfolder
'''
sys.path.append(os.path.join(ROOT_DIR, "Data Scraping", "src"))
sys.path.append(os.path.join(ROOT_DIR, "Data Storing", "src"))
sys.path.append(os.path.join(ROOT_DIR, "Data Warehouse", "src"))

'''
Import fungsi-fungsi ETL dari tiap script
'''
from group_rank_scraper import scrap_group_rank
from detail_scraper import scrap_detail
from sub_unit_scraper import scrap_sub_unit
from label_scraper import scrap_label
from album_scraper import scrap_album
from idol_scraper import scrap_idol
from transformer import transform
from storing import store
from migration import store_dw

'''
Helper log untuk print log ke terminal dan tulis ke pipeline_log.txt
Dilakukan agar tidak bentrok dengan logger masing2 modul
'''
def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    text = f"{timestamp} - INFO - {msg}"
    print(text)
    with open(os.path.join(ROOT_DIR, "pipeline_log.txt"), "a", encoding="utf-8") as f:
        f.write(text + "\n")


'''
Eksekusi penuh ETL (Scraping -> Transform -> Storing -> Migrasi DW)
'''
def run_pipeline():
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}"
    log(f"Memulai proses pipeline ETL batch: {batch_name}")

    # Data Scraping
    log("Memulai proses Data Scraping")
    scrap_group_rank(batch_name)
    scrap_detail(batch_name)
    scrap_sub_unit(batch_name)
    scrap_label(batch_name)
    scrap_album(batch_name)
    scrap_idol(batch_name)
    log("Berhasil melakukan Data Scraping")

    # Preprocessing & Transformation
    log("Memulai proses transformasi dan cleaning data")
    transform(batch_name)
    log("Berhasil melakukan transformasi data")

    # Data Storing ke OLTP (kpopdb)
    log("Memulai proses storing data ke database OLTP (kpopdb)")
    store(batch_name)
    log("Berhasil melakukan storing data OLTP")

    # Migrasi ke Data Warehouse (kpopdw)
    log("Memulai proses migrasi data ke Data Warehouse (kpopdw)")
    store_dw()
    log("Berhasil melakukan migrasi Data Warehouse")

    log(f"Berhasil menjalankan seluruh pipeline ETL batch '{batch_name}'")


'''
Jalankan pipeline berulang secara otomatis setiap N jam
'''
def start_scheduler(interval_hours=1):
    log(f"Memulai automated scheduler pipeline setiap {interval_hours} jam")
    try:
        while True:
            run_pipeline()
            log(f"Scheduler tidur selama {interval_hours} jam sampai eksekusi berikutnya")
            time.sleep(interval_hours * 3600)
    except KeyboardInterrupt:
        log("Scheduler dihentikan oleh user")


if __name__ == "__main__":
    # Untuk run dengan interval (ex: python run_pipeline.py 3)
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        start_scheduler(int(sys.argv[1]))
    else:
        # Untuk tanpa argumen (ex: python run_pipeline.py)
        run_pipeline()
