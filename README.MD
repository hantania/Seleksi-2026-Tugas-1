<h1 align="center">
  <br>
  Seleksi Warga Basdat 2026 <br>
  ETL Project
  <br>
  <br>
</h1>

---

## Author
- **Nama**: Antania Hanjani Yustika Putri
- **NIM**: 18224083

---

## Deskripsi Topik & DBMS

### **Topik Data Scraping: K-Pop Database & Analytical Metrics**
Industri musik K-Pop telah berkembang menjadi fenomena global dengan ekosistem data yang sangat kaya, mencakup data entitas (grup, idol/member, agensi/label, album, lagu, fandom) hingga data metrik performa dinamis (ranking popularitas, jumlah *bias votes*, serta skor penilaian kemampuan seperti *dance*, *vocal*, *stage*, *artistry*, dan *visual*). 

Topik ini dipilih karena memiliki kompleksitas struktur data relasional yang ideal untuk perancangan **RDBMS (OLTP)** sekaligus menyediakan metrik kuantitatif teratur yang sangat cocok untuk pemodelan **Data Warehouse (OLAP)** guna analisis tren industri K-Pop dari waktu ke waktu.

### **Database Management System (DBMS)**
Proyek ini mengimplementasikan **PostgreSQL** sebagai RDBMS pilihan:
- **`kpopdb` (OLTP)**: Menyimpan seluruh entitas terstruktur hasil scraping & transformasi (grup, idol, album, label, fandom, votings, serta riwayat metrik).
- **`kpopdw` (OLAP)**: Menjadi Data Warehouse berbasis *Star Schema* untuk kebutuhan analitik OLAP yang cepat dan efisien.

---

## Cara Menggunakan Scraper & Menjalankan Pipeline

### **Prasyarat & Instalasi Dependency**
Pastikan Python 3.8+ dan PostgreSQL telah terpasang di sistem Anda. Install seluruh *dependency* dengan menjalankan:
```bash
pip install -r requirements.txt
playwright install chromium
```

Pastikan file `.env` di root repositori telah dikonfigurasi dengan kredensial PostgreSQL Anda:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kpopdb
DB_USER=postgres
DB_PASSWORD=your_password

DW_HOST=localhost
DW_PORT=5432
DW_NAME=kpopdw
DW_USER=postgres
DW_PASSWORD=your_password
```

### **1. Menjalankan Seluruh Alur ETL Sekaligus (`run_pipeline.py`)**
Untuk menjalankan proses penuh secara otomatis dari Scraping $\rightarrow$ Preprocessing/Transformation $\rightarrow$ Storing OLTP (`kpopdb`) $\rightarrow$ Migrasi Data Warehouse (`kpopdw`):
```bash
python run_pipeline.py
```

### **2. Menjalankan Scraper Secara Terpisah**
Jika ingin mengeksekusi modul scraper secara individual untuk batch tertentu (misal `batch-2026-07-20`):
```bash
python "Data Scraping/src/group_rank_scraper.py"
python "Data Scraping/src/detail_scraper.py"
python "Data Scraping/src/sub_unit_scraper.py"
python "Data Scraping/src/label_scraper.py"
python "Data Scraping/src/album_scraper.py"
python "Data Scraping/src/idol_scraper.py"
python "Data Scraping/src/transformer.py"
```

Hasil output scraping akan tersimpan otomatis di direktori `Data Scraping/data/<batch_name>/` yang terbagi ke dalam subfolder `raw/`, `sitemap/`, dan `clean/`.

---

## 📄 Penjelasan Struktur File JSON Hasil Scraper

Setelah tahap *transformer* (`transformer.py`) dijalankan, data bersih (*clean data*) akan tersimpan dalam bentuk file JSON dengan struktur sebagai berikut:

1. **`groups.json`**: Menyimpan detail data utama setiap K-Pop grup.
   ```json
   {
     "id_group": 1,
     "name": "BTS",
     "other_name": "Bangtan Boys",
     "status": "ACTIVE",
     "debut_date": "2013-06-13",
     "generation": 3,
     "id_label": 1,
     "id_parent_group": null
   }
   ```
2. **`idols.json`**: Menyimpan biodata lengkap anggota/member grup K-Pop.
   ```json
   {
     "id_idol": 1,
     "stage_name": "Jungkook",
     "full_name": "Jeon Jung-kook",
     "birthday": "1997-09-01",
     "birth_adm_area": "Busan",
     "birth_country": "South Korea",
     "height": 179.0
   }
   ```
3. **`labels.json`**: Menyimpan profil agensi/label musik.
   ```json
   {
     "id_label": 1,
     "name": "BIGHIT MUSIC",
     "founded_year": 2005,
     "founder": "Bang Si-hyuk"
   }
   ```
4. **`albums.json` & `album_tracks.json`**: Menyimpan diskografi album dan daftar trek lagu.
   ```json
   // albums.json
   {
     "id_album": 10,
     "id_group": 1,
     "album_name": "Proof",
     "type": "Anthology Album",
     "release_date": "2022-06-10",
     "language": "Korean"
   }
   ```
5. **`fandoms.json` & `fandom_colors.json`**: Menyimpan nama dan warna identitas fandom resmi.
   ```json
   {
     "id_fandom": 1,
     "id_group": 1,
     "fandom_name": "ARMY"
   }
   ```
6. **`group_metrics.json`**: Menyimpan data snapshot metrik kuantitatif grup (ranking, vote, dan skor kemampuan).
   ```json
   {
     "id_group": 1,
     "scraped_at": "2026-07-20 14:30:15",
     "rank": 1,
     "total_bias_votes": 1250400,
     "dance_score": 9.5,
     "vocal_score": 9.2,
     "stage_score": 9.8,
     "artistry_score": 9.4,
     "visual_score": 9.3
   }
   ```

---

## 📐 Struktur ERD & Diagram Relasional RDBMS

### **1. Entity Relationship Diagram (ERD)**
![KPOPBD ERD](Data%20Storing/design/KPOPBD_ERD.png)

### **2. Diagram Relasional RDBMS**
![KPOPDB Relational](Data%20Storing/design/KPOPDB_Relational.png)

---

## 🔄 Penjelasan Proses Translasi ERD ke Diagram Relasional

Translasi dari ERD ke skema tabel relasional mengikuti kaidah perancangan basis data standar:

1. **Entitas Kuat (Strong Entities)**:
   Entitas seperti `labels`, `idols`, `groups`, `votings`, dan `fans_users` ditranslasikan langsung menjadi tabel independen dengan Primary Key unik (`ID_label`, `ID_idol`, `ID_group`, dll.).

2. **Relasi One-to-Many (1:N)**:
   - `labels` $\rightarrow$ `groups`: Foreign Key `ID_label` diletakkan pada tabel `groups`.
   - `groups` $\rightarrow$ `albums`: Foreign Key `ID_group` diletakkan pada tabel `albums`.
   - `albums` $\rightarrow$ `tracks`: Foreign Key `ID_album` diletakkan pada tabel `tracks`.

3. **Relasi Many-to-Many (M:N)**:
   - `groups` $\leftrightarrow$ `idols`: Ditranslasikan menjadi tabel relasi **`group_idols`** dengan komposit Primary Key (`ID_group`, `ID_idol`, `role`).
   - `fans_users` $\leftrightarrow$ `fandoms`: Ditranslasikan menjadi tabel relasi **`fans_fandoms`** (`ID_user`, `ID_fandom`).
   - `fans_users` $\leftrightarrow$ `groups` (melalui `votings`): Ditranslasikan menjadi tabel **`fans_vote_groups`** (`ID_user`, `ID_group`, `ID_voting`).

4. **Atribut Multivalue (Multivalued Attributes)**:
   - Atribut warna identitas fandom ditranslasikan menjadi tabel tersendiri **`fandom_colors`** dengan komposit Primary Key (`ID_fandom`, `color_identity`).

5. **Spesialisasi & Generalisasi (Hierarchy / Inheritance)**:
   - Entitas `groups` memiliki turunan status (`active_groups`, `disbanded_groups`, `hiatus_groups`). Diterapkan menggunakan metode *Class Hierarchy Mapping* di mana entitas anak menyimpan Primary Key yang sekaligus berfungsi sebagai Foreign Key ke entitas induk `groups`. Konsistensi perpindahan status dijamin oleh **PostgreSQL Trigger** `trg_group_status_changed`.

6. **Relasi Unary (Recursive Relationship)**:
   - Sub-unit grup direpresentasikan melalui Foreign Key rekursif `ID_parent_group` pada tabel `groups` yang merujuk ke `ID_group` induknya.

---

## 📸 Bukti Penyimpanan Data pada DBMS (RDBMS)

Berikut adalah beberapa sampel screenshot bukti query penyimpanan data pada DBMS PostgreSQL (`kpopdb`):

| Tabel / View | Screenshot |
| :--- | :--- |
| **`groups`** | ![Tabel Groups](Data%20Storing/screenshot/tabel_groups.png) |
| **`idols`** | ![Tabel Idols](Data%20Storing/screenshot/tabel_idols.png) |
| **`labels`** | ![Tabel Labels](Data%20Storing/screenshot/tabel_labels.png) |
| **`albums`** | ![Tabel Albums](Data%20Storing/screenshot/tabel_albums.png) |
| **`tracks`** | ![Tabel Tracks](Data%20Storing/screenshot/tabel_tracks.png) |
| **`fandoms`** | ![Tabel Fandoms](Data%20Storing/screenshot/tabel_fandoms.png) |
| **`group_idols`** | ![Tabel Group Idols](Data%20Storing/screenshot/tabel_group_idols.png) |
| **`group_metrics`** | ![Tabel Group Metrics](Data%20Storing/screenshot/tabel_group_metrics.png) |
| **`view_total_score`** | ![View Total Score](Data%20Storing/screenshot/view_total_score.png) |
| **`view_idol_age`** | ![View Idol Age](Data%20Storing/screenshot/view_idol_age.png) |

---

## 🌟 Bonus 1: Data Warehouse & Star Schema

### **1. Perancangan Star Schema**
Data Warehouse (`kpopdw`) dirancang menggunakan pendekatan **Star Schema** untuk mendukung kebutuhan query analitik tingkat tinggi secara efisien tanpa *multi-level JOIN* yang berat.

- **Diagram ERD Data Warehouse**:
  ![KPOPDW ERD](Data%20Warehouse/design/KPOPDW_ERD.png)
- **Diagram Relasional Data Warehouse**:
  ![KPOPDW Relational](Data%20Warehouse/design/KPOPDW_Relational.png)

### **2. Struktur Tabel Data Warehouse**
- **Tabel Fakta (`fact_group_metrics`)**: Menyimpan metrik kuantitatif (`rank`, `total_bias_votes`, `dance_score`, `vocal_score`, `stage_score`, `artistry_score`, `visual_score`, `total_score`) dan kunci dimensi (`id_time`, `id_group`, `id_label`, `id_fandom`).
- **Tabel Dimensi**:
  - `dim_group`: Atribut profil grup (`group_name`, `status`, `debut_date`, `is_sub_unit`).
  - `dim_label`: Atribut agensi (`name`, `founded_year`, `founder`).
  - `dim_fandom`: Atribut fandom (`fandom_name`).
  - `dim_time`: Hirarki waktu (`full_date`, `year`, `quarter`, `month`, `day`).

### **3. Contoh Query Analitik di Data Warehouse**

#### *Query 1: Tren Rata-rata Skor Kemampuan Grup Berdasarkan Agensi/Label*
```sql
SELECT 
    l.name AS label_name,
    ROUND(AVG(f.total_score), 2) AS avg_total_score,
    ROUND(AVG(f.vocal_score), 2) AS avg_vocal_score,
    ROUND(AVG(f.dance_score), 2) AS avg_dance_score
FROM fact_group_metrics f
JOIN dim_label l ON f.id_label = l.id_label
GROUP BY l.name
ORDER BY avg_total_score DESC;
```

#### *Query 2: Perubahan Ranking & Perolehan Vote Grup dari Waktu ke Waktu*
```sql
SELECT 
    g.group_name,
    t.full_date,
    f.rank,
    f.total_bias_votes,
    f.total_score
FROM fact_group_metrics f
JOIN dim_group g ON f.id_group = g.id_group
JOIN dim_time t ON f.id_time = t.id_time
ORDER BY g.group_name, t.full_date ASC;
```

---

## 🤖 Bonus 2: Automated Scheduling & Anti-Redundansi

### **1. Automated Scheduling (`run_pipeline.py`)**
Seluruh alur eksekusi telah diintegrasikan ke dalam `run_pipeline.py` yang mendukung penjadwalan otomatis secara berkala.

- **Menjalankan Scheduler Berkelanjutan per N Jam (Contoh: Setiap 2 jam)**:
  ```bash
  python run_pipeline.py 2
  ```
- **Menjalankan Scheduler Harian (Setiap 24 jam)**:
  ```bash
  python run_pipeline.py 24
  ```

### **2. Penanganan Anti-Redundansi Data**
- **Di Database OLTP (`kpopdb`)**: Menggunakan klausul `CREATE TABLE IF NOT EXISTS` dan `ON CONFLICT (...) DO NOTHING` / `DO UPDATE`. Entitas master (`groups`, `idols`, `labels`, `fandoms`) tidak akan terduplikat meskipun scraping dilakukan berulang kali.
- **Di Data Warehouse (`kpopdw`)**: Menggunakan `UNIQUE(id_group, id_time)` pada `fact_group_metrics` dengan klausul `ON CONFLICT (id_group, id_time) DO UPDATE`. Setiap snapshot metrik diikat secara unik ke dimensi waktu (`id_time`), menjamin tidak ada duplikasi data fakta untuk periode waktu yang sama.

### **3. Sistem Logging Terpisah & Rapi**
- `pipeline_log.txt`: Ringkasan status utama alur eksekusi `run_pipeline.py`.
- `Data Scraping/scrap_log.txt`: Catatan rincian proses ekstraksi web.
- `Data Storing/storing_log.txt`: Catatan rincian penyisipan data OLTP.
- `Data Warehouse/warehouse_log.txt`: Catatan rincian migrasi Data Warehouse OLAP.

---

## 📚 Referensi

1. **Website Sumber Data**:
   - [Kpopping - K-Pop Encyclopedia & Rankings](https://kpopping.com)
2. **Library & Tools Python**:
   - `requests` (v2.31+) - HTTP Request
   - `beautifulsoup4` (v4.12+) - HTML Parsing & Scrape
   - `playwright` (v1.40+) - Headless Browser Automation
   - `psycopg2-binary` (v2.9+) - PostgreSQL Database Adapter
   - `python-dotenv` (v1.0+) - Environment Variable Manager
3. **Database**:
   - PostgreSQL (v15+)