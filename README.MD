<h1 align="center">
  <br>
  Seleksi Warga Basdat 2026 <br>
  ETL Project
  <br>
  <br>
</h1>

<h2 align="center">
  <br>
  Data Scraping, Modeling, Storing, Warehousing, Automated Scheduling and Query Optimization
  <br>
  <br>
  Antania Hanjani Yustika Putri - 18224083
  <br>
  <br>
</h2>

---

## Deskripsi Proyek

[Kpopping](https://kpopping.com) merupakan website ensiklopedia K-Pop yang menyediakan berbagai informasi mengenai industri K-Pop. Informasi tersebut dikelompokkan ke dalam beragam kategori unik, seperti kategori idol yang mengikuti wajib militer, group sesuai generasi, dan kategori lainnya. Berdasarkan kategori yang tersedia, kategori yang dipilih adalah **50 Group K-Pop Terpopuler Berdasarkan Bias Votes**. 

Topik ini dipilih berdasarkan ketertarikan pribadi terhadap dunia K-Pop sekaligus karena data yang disediakan oleh KPopping sangat beragam. Keberagaman data tersebut memungkinkan analisis yang lebih mendalam mengenai faktor-faktor yang berkaitan dengan popularitas suatu grup K-Pop

---

## Prerequisite

Sebelum menjalankan proyek, pastikan telah memenuhi prasyarat berikut:

1. Clone repositori:
   ```bash
   git clone <link nnti diisi sm sy>
   ```

2. Masuk ke direktori proyek:
   ```bash
   cd "seleksi-2026-tugas-1"
   ```

3. Install dependensi:
   ```bash
   pip install -r requirements.txt
   playwright install chromium
   ```

---

## Data Scraping

### 1. Cara Menggunakan Scraper

Terdapat 2 cara untuk menjalankan proses scraping yang telah dibuat:

#### Cara 1: Menjalankan Script Scraping Satu per Satu
Pindah ke direktori `Data Scraping/src` 
```bash
cd "Data Scraping/src"
```
lalu eksekusi script sesuai urutan berikut:
```bash
python group_rank_scraper.py
python detail_scraper.py
python sub_unit_scraper.py
python label_scraper.py
python album_scraper.py
python idol_scraper.py
python transformer.py
```

#### Cara 2: Menjalankan Pipeline
Eksekusi script pipeline dari root direktori proyek untuk menjalankan seluruh alur secara otomatis (Scraping > Transform > Storing > Migrasi DW):
```bash
python run_pipeline.py
```

### 2. Hasil Data dari Scraping

Hasil scraping tersimpan pada direktori `Data Scraping/data/<batch_name>/` yang dibagi menjadi 2 jenis:

- **Raw Data (`raw/`)**: Data mentah tanpa pengolahan lebih lanjut.
- **Clean Data (`clean/`)**: Data yang telah dipreprocess oleh `transformer.py`

Struktur file JSON data bersih (`clean/`):

1. `groups.json`
   ```json
   {
     "id_group": 1,
     "name": "BTS",
     "other_name": "Bangtan Boys",
     "status": "ACTIVE",
     "debut_date": "2013-06-13",
     "id_label": 1,
     "id_parent_group": null
   }
   ```

2. `group_metrics.json`
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

3. `idols.json`
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

4. `labels.json`
   ```json
   {
     "id_label": 1,
     "name": "BIGHIT MUSIC",
     "founded_year": 2005,
     "founder": "Bang Si-hyuk"
   }
   ```

5. `albums.json`
   ```json
   {
     "id_album": 10,
     "id_group": 1,
     "name": "Proof",
     "type": "Anthology Album",
     "release_date": "2022-06-10",
     "language": "Korean"
   }
   ```

6. `fandoms.json`
   ```json
   {
     "id_fandom": 1,
     "id_group": 1,
     "name": "ARMY"
   }
   ```

---

## Data Modeling

### 1a. Struktur ERD

![KPOPBD ERD](Data%20Storing/design/KPOPBD_ERD.png)

### 1b. Asumsi ERD

![KPOPBD ERD Asumsi](Data%20Storing/design/KPOPDB_ERD_Asumsi.png)

### 2. Diagram Relasional

![KPOPDB Relational](Data%20Storing/design/KPOPDB_Relational.png)

### 3. Proses Translasi ERD ke Diagram Relasional

Translasi dari ERD ke Diagram Relasional dilakukan sesuai aturan berikut:

#### 3.1 Pemetaan Entity Menjadi Relasi
- **Strong Entity**
  
  Cara: Buat relasi baru, atributnya berisi semua atribut strong entity, dan Primary Key nya yaitu PK strong entity 

  ![Strong Entity](Data%20Storing/design/strong_entity.png)
  
- **Weak Entity**
  
  Cara: Buat relasi baru, atributnya berisi semua atribut weak entity + PK strong entity yang tertaut. Kemudian,s jadikan PK strong entity + discriminator weak entity sebagai Primary Key relasi baru

  ![Weak Entity](Data%20Storing/design/weak_entity.png)

#### 3.2 Pemetaan Relationship Menjadi Relasi
- **1 to 1 Relationship**

  Cara: Ambil Primary Key dari salah satu strong entity ke entitas lainnya, lalu jadikan sebagai Foreign Key

  ![1 to 1](Data%20Storing/design/1%20to%201.png)

- **1 to M Relationship**

  Cara: Ambil Primary Key dari entitas pada sisi "one" (1), taruh di entitas pada sisi "many" (M), lalu jadikan sebagai Foreign Key

  ![1 to M](Data%20Storing/design/1%20to%20M.png)

- **M to M Relationship**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing relasi yang terhubung. Kemudian, jadikan gabungan PK kedua entitas sebagai Primary Key relasi baru

  ![M to M](Data%20Storing/design/M%20to%20M.png)

#### 3.3 Pemetaan Lain-lain
- **Composite Attribute**

  Cara: Ambil atribut paling dalam dari atribut komposit, jadikan atribut di relasi baru

  ![Composite Attribute](Data%20Storing/design/composite_attribute.png)

- **Multivalue Attribute**
  
  Cara: Buat relasi baru, atributnya berisi PK strong entity dan atribut multivalue. Lalu jadikan gabungan kedua atribut sebagai Primary Key relasi tersebut

  ![Multivalue Attribute](Data%20Storing/design/multivalue_attribute.png)

- **Derived Attribute**
  
  Cara: Hilangkan derived attribute dari entity awal. Sementara itu, hitung saat query atau jadikan View

  ![Derived Attribute](Data%20Storing/design/derived_attribute.png)

- **Specialization (Inheritance)**

  Cara: Ada 2 tipe. Saya memilih menggunakan transformasi tipe 1, yaitu buat relasi baru yang isinya seluruh atribut entitas anak + ambil PK parent (sebagai FK ke parent), sementara entitas parent-nya tidak dihapus. (Tambahan: Konsistensi perpindahan status dijamin oleh trigger)

  ![Specialization](Data%20Storing/design/specialization.png)

- **Unary Relationship**

  Cara: Karena 1 to M, sebagaimana pemetaan 1 to M yang menaruh PK sisi 1 ke many, tetapi di sini entitasnya sama, maka hanya membedakan nama kolom (misalnya `ID_parent_group`) yang ditaruh pada tabel `groups` dan merujuk kembali ke Primary Key `ID_group`.

  ![Unary](Data%20Storing/design/unary.png)

- **Ternary Relationship**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing entitas yang terkait dalam relasi ternary tersebut, lalu jadikan gabungan PK ketiga entitas sebagai Primary Key relasi baru

  ![Ternary](Data%20Storing/design/ternary.png)

- **Relationship Attribute**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing entitas yang terhubung, lalu tambahkan atribut relasi tersebut sebagai atribut tambahan.

  ![Relationship Attribute](Data%20Storing/design/relationship_attribute.png)

---

## Data Storing

Proyek ini mengimplementasikan **PostgreSQL** sebagai RDBMS (OLTP).

### 1. Langkah-Langkah Data Storing

1. Buat database PostgreSQL baru dengan konfigurasi berikut:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=kpopdb
   DB_USER=postgres
   DB_PASSWORD=your_password
   ```

2. Jalankan script `storing.py`
   ```bash
   python "Data Storing/src/storing.py"
   ```

3. Untuk menggunakan OLTP, perlu diingat bahwa data memuat karakter bahasa Korea (Hangeul) dan aksen khusus, maka atur codepage terminal ke UTF-8:

   ```cmd
   chcp 65001
   ```

4. Masuk ke Database KPOPDB
   ```bash
   psql -U postgres -d kpopdb
   ```

5. Tentukan Encoding UTF8 di Database
   ```sql
   \encoding UTF8
   ```

### 2. Bukti Storing

Berikut adalah bukti penyimpanan seluruh tabel dan view pada database KPOPDB:

| Nama Tabel / View / Trigger | Screenshot |
| :--- | :--- |
| **`groups`** | ![Tabel Groups](Data%20Storing/screenshot/tabel_groups.png) |
| **`active_groups`** | ![Tabel Active Groups](Data%20Storing/screenshot/tabel_active_groups.png) |
| **`disbanded_groups`** | ![Tabel Disbanded Groups](Data%20Storing/screenshot/tabel_disbanded_groups.png) |
| **`hiatus_groups`** | ![Tabel Hiatus Groups](Data%20Storing/screenshot/tabel_hiatus_groups.png) |
| **`idols`** | ![Tabel Idols](Data%20Storing/screenshot/tabel_idols.png) |
| **`labels`** | ![Tabel Labels](Data%20Storing/screenshot/tabel_labels.png) |
| **`albums`** | ![Tabel Albums](Data%20Storing/screenshot/tabel_albums.png) |
| **`tracks`** | ![Tabel Tracks](Data%20Storing/screenshot/tabel_tracks.png) |
| **`fandoms`** | ![Tabel Fandoms](Data%20Storing/screenshot/tabel_fandoms.png) |
| **`fandom_colors`** | ![Tabel Fandom Colors](Data%20Storing/screenshot/tabel_fandom_colors.png) |
| **`group_idols`** | ![Tabel Group Idols](Data%20Storing/screenshot/tabel_group_idols.png) |
| **`group_metrics`** | ![Tabel Group Metrics](Data%20Storing/screenshot/tabel_group_metrics.png) |
| **`fans_users`** | ![Tabel Fans Users](Data%20Storing/screenshot/tabel_fans_users.png) |
| **`fans_fandoms`** | ![Tabel Fans Fandoms](Data%20Storing/screenshot/tabel_fans_fandoms.png) |
| **`votings`** | ![Tabel Votings](Data%20Storing/screenshot/tabel_votings.png) |
| **`fans_vote_groups`** | ![Tabel Fans Vote Groups](Data%20Storing/screenshot/tabel_fans_vote_groups.png) |
| **`view_total_score`** | ![View Total Score](Data%20Storing/screenshot/view_total_score.png) |
| **`view_idol_age`** | ![View Idol Age](Data%20Storing/screenshot/view_idol_age.png) |
| **`trigger_specialization`** | ![Trigger Specialization](Data%20Storing/screenshot/trigger_specialization.png) |

---

## BONUS: Data Warehouse

### Perancangan Data Warehouse

Data Warehouse (OLAP) dikhususkan untuk kebutuhan analitik, sehingga rancangannya dibuat seefisien mungkin untuk mencapai tujuan analitik.

Tujuan spesifik dari OLAP proyek ini adalah untuk **analisis group metric**, dengan melihat detail dari dimensi group, label, waktu, dan fandom. 

Setelah mempertimbangkan efisiensi query analitik, digunakan struktur **Star Schema** agar meminimalkan operasi JOIN yang berat.

### 1a. Struktur ERD Data Warehouse

![KPOPDW ERD](Data%20Warehouse/design/KPOPDW_ERD.png)

### 1b. Asumsi ERD Data Warehouse

### 2. Diagram Relasional Data Warehouse

![KPOPDW Relational](Data%20Warehouse/design/KPOPDW_Relational.png)

### 3. Cara Migrasi ke Data Warehouse

1. Buat database PostgreSQL baru dengan konfigurasi berikut:
   ```env
   DW_HOST=localhost
   DW_PORT=5432
   DW_NAME=kpopdw
   DW_USER=postgres
   DW_PASSWORD=your_password
   ```

2. Jalankan script migrasi ke Data Warehouse:
   ```bash
   python "Data Warehouse/src/migration.py"
   ```

3. Pada terminal Windows, atur `chcp 65001` dan `\encoding UTF8` karena data memuat bahasa Korea.

### 4. Bukti Storing di Data Warehouse

| Tabel Data Warehouse | Screenshot |
| :--- | :--- |
| **`fact_group_metrics`** | *(Placeholder Screenshot Tabel Fact Group Metrics)* |
| **`dim_group`** | *(Placeholder Screenshot Tabel Dim Group)* |
| **`dim_label`** | *(Placeholder Screenshot Tabel Dim Label)* |
| **`dim_fandom`** | *(Placeholder Screenshot Tabel Dim Fandom)* |
| **`dim_time`** | *(Placeholder Screenshot Tabel Dim Time)* |

---

### 5. Query Analitik

Berikut adalah placeholder query analitik pada Data Warehouse (`kpopdw`):

#### 1. Query Analitik 1

#### Kode Query SQL:
```sql
SELECT 
    l.name AS label_name,
    COUNT(DISTINCT f.id_group) AS total_groups,
    ROUND(AVG(f.total_score), 2) AS avg_total_score,
    SUM(f.total_bias_votes) AS total_bias_votes
FROM fact_group_metrics f
JOIN dim_label l ON f.id_label = l.id_label
GROUP BY l.name
ORDER BY avg_total_score DESC;
```

#### Hasil Query:
*(Placeholder Gambar Hasil Query 1)*

---

#### 2. Query Analitik 2

#### Kode Query SQL:
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

#### Hasil Query:
*(Placeholder Gambar Hasil Query 2)*

---

#### 3. Query Analitik 3

#### Kode Query SQL:
```sql
SELECT 
    g.group_name,
    f.rank,
    f.total_bias_votes,
    f.dance_score,
    f.vocal_score,
    f.stage_score
FROM fact_group_metrics f
JOIN dim_group g ON f.id_group = g.id_group
ORDER BY f.total_bias_votes DESC
LIMIT 10;
```

#### Hasil Query:
*(Placeholder Gambar Hasil Query 3)*

---

## BONUS: AUTOMATED SCHEDULING

Untuk memudahkan proses ETL, dibuat penjadwalan otomatis (Automated Scheduling) dengan menggunakan **Windows Task Scheduler**.

Idealnya penjadwalan dijalankan 1 hari sekali. Namun untuk memenuhi pengujian dan evaluasi project ini, penjadwalan dikonfigurasi untuk berjalan **6 jam sekali**.

Berikut adalah bukti screenshot langkah-langkah pembuatan Task Scheduler:

| Langkah | Screenshot Pengaturan Task Scheduler |
| :--- | :--- |
| **Langkah 1: Membuat Task Baru** | ![Step 1](Bonus/Automated%20Scheduling/step%201.png) |
| **Langkah 2: Menentukan Nama dan Trigger** | ![Step 2](Bonus/Automated%20Scheduling/step%202.png) |
| **Langkah 3: Konfigurasi Interval 6 Jam** | ![Step 3](Bonus/Automated%20Scheduling/step%203.png) |
| **Langkah 4: Menentukan Action (Run Program)** | ![Step 4](Bonus/Automated%20Scheduling/step%204.png) |
| **Langkah 5: Mengarahkan Executable Python & Argument Script** | ![Step 5](Bonus/Automated%20Scheduling/step%205.png) |
| **Langkah 6: Memastikan Working Directory Teratur** | ![Step 6](Bonus/Automated%20Scheduling/step%206.png) |
| **Langkah 7: Meninjau Ringkasan Task Scheduler** | ![Step 7](Bonus/Automated%20Scheduling/step%207.png) |
| **Langkah 8: Verifikasi Task Berhasil Berjalan** | ![Step 8](Bonus/Automated%20Scheduling/step%208.png) |

---

## QUERY OPTIMIZATION

*(Placeholder section untuk Query Optimization)*

---

## Referensi

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