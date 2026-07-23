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

**Kpopping** merupakan website ensiklopedia K-Pop yang menyediakan berbagai informasi mengenai industri K-Pop. Informasi tersebut dikelompokkan ke dalam beragam kategori unik, seperti kategori idol yang mengikuti wajib militer, group sesuai generasi, dan kategori lainnya. Berdasarkan kategori yang tersedia, kategori yang dipilih adalah **50 Group K-Pop Terpopuler Berdasarkan Bias Votes**. 

Topik ini dipilih berdasarkan ketertarikan pribadi terhadap dunia K-Pop sekaligus karena data yang disediakan oleh KPopping sangat beragam. Keberagaman data tersebut memungkinkan analisis yang lebih mendalam mengenai faktor-faktor yang berkaitan dengan popularitas suatu grup K-Pop

---

## Prasayarat

Sebelum menjalankan proyek, lakukan:

1. Clone repositori:
   ```bash
   git clone https://github.com/hantania/Seleksi-2026-Tugas-1
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

Terdapat 2 cara untuk menjalankan scraper:

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
Eksekusi script di root direktori proyek untuk menjalankan seluruh alur secara otomatis (Scraping > Transform > Storing > Migrasi DW):
```bash
python run_pipeline.py
```

### 2. Hasil Data dari Scraping

Hasil scraping tersimpan pada direktori `Data Scraping/data/<batch_name>/` yang dibagi menjadi 2 jenis:

- **Raw Data (`raw/`)**: Data mentah tanpa pengolahan lebih lanjut
- **Clean Data (`clean/`)**: Data yang telah dipreprocess oleh `transformer.py` sehingga sudah memiliki id

Struktur file JSON data bersih (`clean/`):

1. `raw_group_details.json`
   ```json
    {
        "name": "Red Velvet",
        "other_name": "レッドベルベット",
        "status": "Active",
        "debut_date": "2014-08-01",
        "generation": "3",
        "active_years": "2014-present"
    }
   ```

2. `raw_group_rank.json`
   ```json
    {
        "name": "Red Velvet",
        "scraped_at": "2026-07-22 17:38:19",
        "rank": "8",
        "total_bias_votes": "2,588"
    }
   ```

3. `raw_group_score.json`
   ```json
    {
        "group_name": "Red Velvet",
        "dance_score": "79",
        "vocal_score": "90",
        "stage_score": "81",
        "artistry_score": "87",
        "visual_score": "88"
    }
   ```

4. `raw_idols.json`
   ```json
    {
        "stage_name": "Jaemin",
        "full_name": "Na Jae-min",
        "birthday": "2000-08-13 (Age 25)",
        "birthplace": "Seoul, South Korea",
        "height": "177 cm"
    }
   ```

5. `raw_labels.json`
   ```json
    {
        "name": "SM Entertainment",
        "founded_year": "1989",
        "founder": "Lee Soo Man"
    }
   ```

6. `raw_albums.json`
   ```json
    {
        "name": "BORN PINK",
        "type": "STUDIO",
        "release_date": "2022-09-16",
        "language": "Korean",
        "description": "Born Pink is the second studio album by BLACKPINK, released on September 16, 2022, by YG Entertainment and Interscope Records."
    }
   ```

2. `raw_fandoms.json`
   ```json
    {
        "group_name": "Dreamcatcher",
        "fandom_name": "InSomnia",
        "color_identity": [
            "PANTONE Black 6 C",
            "PANTONE 7623 C",
            "PANTONE P 10-6 C"
        ]
    }
   ```

---

## Data Modeling

### 1a. Struktur ERD

<img src="./Data Storing/design/KPOPBD_ERD.png" alt="KPOPBD ERD" width="100%">

### 1b. Asumsi ERD

<img src="./Data Storing/design/KPOPDB_ERD_Asumsi.png" alt="KPOPBD ERD Asumsi" width="100%">

### 2. Diagram Relasional

<img src="./Data Storing/design/KPOPDB_Relational.png" alt="KPOPDB Relational" width="100%">

### 3. Proses Translasi ERD ke Diagram Relasional

Translasi dari ERD ke Diagram Relasional dilakukan sesuai aturan berikut:

#### 3.1 Pemetaan Entity Menjadi Relasi
- **Strong Entity**
  
  Cara: Buat relasi baru, atributnya berisi semua atribut strong entity, dan Primary Key nya yaitu PK strong entity 

  <img src="./Data Storing/design/strong_entity.png" alt="Strong Entity" width="100%">
  
- **Weak Entity**
  
  Cara: Buat relasi baru, atributnya berisi semua atribut weak entity + PK strong entity yang tertaut. Kemudian,sjadikan PK strong entity + discriminator weak entity sebagai Primary Key relasi baru

  <img src="./Data Storing/design/weak_entity.png" alt="Weak Entity" width="100%">

  Hasil pemetaan:
  - tracks: (**ID_album**, **title**, genre)
  - group_metrics: (**ID_group, scraped_at,** rank, total_bias_votes, dance_score, vocal_score, stage_score, artistry_score, visual_score)
  
  FK:
  - tracks(ID_album) → albums(ID_album)
  - group_metrics(ID_group) → groups(ID_group)

#### 3.2 Pemetaan Relationship Menjadi Relasi
- **1 to 1 Relationship**

  Cara: Ambil Primary Key dari salah satu strong entity ke entitas lainnya, lalu jadikan sebagai Foreign Key

  <img src="./Data Storing/design/1 to 1.png" alt="1 to 1" width="100%">

  Hasil pemetaan:
  - fandoms: (**ID_fandom**, ID_group, name)

  FK:
  - fandoms(ID_group) → groups(ID_group)

- **1 to M Relationship**

  Cara: Ambil Primary Key dari entitas pada sisi "one" (1), taruh di entitas pada sisi "many" (M), lalu jadikan sebagai Foreign Key

  <img src="./Data Storing/design/1 to M.png" alt="1 to M" width="100%">

  Hasil pemetaan:
  - groups: (**ID_group**, ID_label, name, other_name, status, debut_date, generation)
  - albums: (**ID_album**, ID_group, name, type, release_date, language, description)
  
  FK:
  - groups(ID_label) → labels(ID_label)
  - albums(ID_group) → groups(ID_group) 

- **M to N Relationship**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing relasi yang terhubung. Kemudian, jadikan gabungan PK kedua entitas sebagai Primary Key relasi baru

  <img src="./Data Storing/design/M to M.png" alt="M to M" width="100%">

  Hasil pemetaan:
  - group_idols: (**ID_group, ID_idol**, role)
  - fans_fandoms: (**ID_user, ID_fandom**)

  FK:
  - group_idols(ID_group) → groups(ID_group)
  - group_idols(ID_idol) → idols(ID_idol)
  - fans_fandoms(ID_user) → fans_user(ID_user)
  - fans_fandoms(ID_fandom) → fandoms(ID_fandom)

#### 3.3 Pemetaan Lain-lain
- **Composite Attribute**

  Cara: Ambil atribut paling dalam dari atribut komposit, jadikan atribut di relasi baru

  <img src="./Data Storing/design/composite_attribute.png" alt="Composite Attribute" width="100%">
  
  Hasil pemetaan:
  - idols: (**ID_idol**, stage_name, full_name, birthday, birth_adm_area, birth_country, height)

- **Multivalue Attribute**
  
  Cara: Buat relasi baru, atributnya berisi PK strong entity dan atribut multivalue. Lalu jadikan gabungan kedua atribut sebagai Primary Key relasi tersebut

  <img src="./Data Storing/design/multivalue_attribute.png" alt="Multivalue Attribute" width="100%">

  Hasil pemetaan:
  - fandom_colors: (**ID_fandom, color_identity**)
  - group_idols: (**ID_group, ID_idol, role**)

  FK:
  - fandom_colors(ID_fandom) → fandoms(ID_fandom)
  - group_idols(ID_group) → groups(ID_group)
  - group_idols(ID_idol) → idols(ID_idol)

- **Derived Attribute**
  
  Cara: Hilangkan derived attribute dari entity awal. Sementara itu, hitung saat query atau jadikan View

  <img src="./Data Storing/design/derived_attribute.png" alt="Derived Attribute" width="100%">

  Hasil pemetaan:
  - group_metrics(total_score()) menjadi view_total_score
  - idols(age()) menjadi view_idol_age

- **Specialization**

  Cara: Ada 2 tipe. Saya memilih menggunakan transformasi tipe 1, yaitu buat relasi baru yang isinya seluruh atribut entitas anak + ambil PK parent (sebagai FK ke parent), sementara entitas parent-nya tidak dihapus. (Tambahan: Konsistensi perpindahan status dijamin oleh trigger)

  <img src="./Data Storing/design/specialization.png" alt="Specialization" width="100%">

  Hasil pemetaan:
  - active_group: (**ID_group**, latest_comeback_date)
  - hiatus_group: (**ID_group**, hiatus_year, hiatus_reason)
  - disbanded_group: (**ID_group**, disbanded_year, disbanded_reason)

  FK:
  - active_groups(ID_group) → groups(ID_group)
  - hiatus_groups(ID_group) → groups(ID_group)
  - disbanded_groups(ID_group) → groups(ID_group)

- **Unary Relationship**

  Cara: Karena 1 to M, sebagaimana pemetaan 1 to M yang menaruh PK sisi 1 ke many, tetapi di sini entitasnya sama, maka hanya membedakan nama kolom (misalnya `ID_parent_group`) yang ditaruh pada tabel `groups` dan merujuk kembali ke Primary Key `ID_group`.

  <img src="./Data Storing/design/unary.png" alt="Unary" width="100%">

  Hasil pemetaan:
  - groups: (**ID_group**, ID_label, name, other_name, status, debut_date, generation, ID_parent_group)

  FK:
  - groups(ID_parent_group) → groups(ID_group)

- **Ternary Relationship**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing entitas yang terkait dalam relasi ternary tersebut, lalu jadikan gabungan PK ketiga entitas sebagai Primary Key relasi baru

  <img src="./Data Storing/design/ternary.png" alt="Ternary" width="100%">

  Hasil pemetaan:
  - fans_vote_groups: (**ID_user, ID_voting, ID_group**, vote_date)

  FK:
  - fans_vote_groups(ID_user) → fans_users(ID_user)
  - fans_vote_groups(ID_voting) → votings(ID_voting)
  - fans_vote_groups(ID_group) → groups(ID_group)

- **Relationship Attribute**

  Cara: Buat relasi baru, atributnya berisi PK dari masing-masing entitas yang terhubung, lalu tambahkan atribut relasi tersebut sebagai atribut tambahan.

  <img src="./Data Storing/design/relationship_attribute.png" alt="Relationship Attribute" width="100%">

  Hasil pemetaan:
  - group_idols: (**ID_group, ID_idol**, role)
  - fans_vote_groups: (**ID_user, ID_user, ID_group**, vote_date)

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

3. Untuk menggunakan OLTP, perlu diingat bahwa data memuat karakter bahasa Korea (Hangeul) dan aksen khusus, maka atur codepage terminal ke UTF-8

   ```cmd
   chcp 65001
   ```

4. Masuk ke Database KPOPDB
   ```bash
   psql -U postgres -d kpopdb
   ```

5. Encoding UTF8 di Database
   ```sql
   \encoding UTF8
   ```

### 2. Bukti Storing

Berikut adalah bukti penyimpanan seluruh tabel dan view pada database KPOPDB:

| Nama Tabel / View / Trigger | Screenshot |
| :--- | :--- |
| **`groups`** | <img src="./Data Storing/screenshot/tabel_groups.png" alt="Tabel Groups" width="100%"> |
| **`active_groups`** | <img src="./Data Storing/screenshot/tabel_active_groups.png" alt="Tabel Active Groups" width="100%"> |
| **`disbanded_groups`** | <img src="./Data Storing/screenshot/tabel_disbanded_groups.png" alt="Tabel Disbanded Groups" width="100%"> |
| **`hiatus_groups`** | <img src="./Data Storing/screenshot/tabel_hiatus_groups.png" alt="Tabel Hiatus Groups" width="100%"> |
| **`idols`** | <img src="./Data Storing/screenshot/tabel_idols.png" alt="Tabel Idols" width="100%"> |
| **`labels`** | <img src="./Data Storing/screenshot/tabel_labels.png" alt="Tabel Labels" width="100%"> |
| **`albums`** | <img src="./Data Storing/screenshot/tabel_albums.png" alt="Tabel Albums" width="100%"> |
| **`tracks`** | <img src="./Data Storing/screenshot/tabel_tracks.png" alt="Tabel Tracks" width="100%"> |
| **`fandoms`** | <img src="./Data Storing/screenshot/tabel_fandoms.png" alt="Tabel Fandoms" width="100%"> |
| **`fandom_colors`** | <img src="./Data Storing/screenshot/tabel_fandom_colors.png" alt="Tabel Fandom Colors" width="100%"> |
| **`group_idols`** | <img src="./Data Storing/screenshot/tabel_group_idols.png" alt="Tabel Group Idols" width="100%"> |
| **`group_metrics`** | <img src="./Data Storing/screenshot/tabel_group_metrics.png" alt="Tabel Group Metrics" width="100%"> |
| **`fans_users`** | <img src="./Data Storing/screenshot/tabel_fans_users.png" alt="Tabel Fans Users" width="100%"> |
| **`fans_fandoms`** | <img src="./Data Storing/screenshot/tabel_fans_fandoms.png" alt="Tabel Fans Fandoms" width="100%"> |
| **`votings`** | <img src="./Data Storing/screenshot/tabel_votings.png" alt="Tabel Votings" width="100%"> |
| **`fans_vote_groups`** | <img src="./Data Storing/screenshot/tabel_fans_vote_groups.png" alt="Tabel Fans Vote Groups" width="100%"> |
| **`view_total_score`** | <img src="./Data Storing/screenshot/view_total_score.png" alt="View Total Score" width="100%"> |
| **`view_idol_age`** | <img src="./Data Storing/screenshot/view_idol_age.png" alt="View Idol Age" width="100%"> |
| **`trigger_specialization`** | <img src="./Data Storing/screenshot/trigger_specialization.png" alt="Trigger Specialization" width="100%"> |

---

## BONUS: Data Warehouse

### Perancangan Data Warehouse

Data Warehouse (OLAP) dikhususkan untuk kebutuhan analitik, sehingga rancangannya dibuat seefisien mungkin untuk mencapai tujuan analitik.

Tujuan spesifik dari OLAP proyek ini adalah untuk **analisis group metric**, dengan melihat detail dari dimensi group, label, waktu, dan fandom. 

Setelah mempertimbangkan efisiensi query analitik, digunakan struktur **Star Schema** agar meminimalkan operasi JOIN yang berat.

### 1a. Struktur ERD Data Warehouse

<img src="./Data Warehouse/design/KPOPDW_ERD.png" alt="KPOPDW ERD" width="100%">

### 1b. Asumsi ERD Data Warehouse

### 2. Diagram Relasional Data Warehouse

<img src="./Data Warehouse/design/KPOPDW_Relational.png" alt="KPOPDW Relational" width="100%">

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
| **`dim_group`** | <img src="./Data Warehouse/screenshot/dim_group.png" alt="Dim Group" width="100%"> |
| **`dim_label`** | <img src="./Data Warehouse/screenshot/dim_label.png" alt="Dim Label" width="100%"> |
| **`dim_fandom`** | <img src="./Data Warehouse/screenshot/dim_fandom.png" alt="Dim Fandom" width="100%"> |
| **`dim_time`** | <img src="./Data Warehouse/screenshot/dim_time.png" alt="Dim Time" width="100%"> |

---

### 5. Query Analitik

#### Kode Query SQL:
```sql
SELECT 
    l.name AS label_name,
    COUNT(DISTINCT f.id_group) AS total_group,
    SUM(f.total_bias_votes) AS total_bias_votes,
    ROUND(AVG(f.total_score),2) AS avg_total_score
FROM fact_group_metrics f
JOIN dim_label l USING (id_label)
GROUP BY l.name
ORDER BY total_bias_votes DESC;
```

#### Hasil Query:
<img src="./Data Warehouse/screenshot/query_analitik.png" alt="Hasil Query Analitik" width="100%">

---

## BONUS: AUTOMATED SCHEDULING

Untuk memudahkan proses ETL, dibuat penjadwalan otomatis (Automated Scheduling) dengan menggunakan **Windows Task Scheduler**.

Idealnya penjadwalan dijalankan 1 hari sekali.



---

## BONUS: QUERY OPTIMIZATION

---

### 1. Kasus 1

#### **Deskripsi**:
Mencari daftar track dari album yang dirilis pada tahun 2020 beserta nama group yang merilis album tersebut.

#### **(Before) Execution Plan**:
Dominan seq scan, index yang digunakan hanya index primary key
<img src="./Query Optimization/screenshot/kasus 1_before.png" alt="Kasus 1 Before Optimization" width="100%">

#### **Upaya Optimizing**
1. SQL Tuning: Menyederhanakan subquery menjadi JOIN
2. SQL Tuning: Mengubah EXTRACT tanggal menjadi perbandingan (>= <=)
3. Indexing: Membuat idx_albums_release_date (B-Tree), pada kolom release_date di tabel albums, untuk memfilter 'rentang (>= <=)' tanggal
4. Indexing: Membuat idx_albums_id_group (Hash), pada kolom id_group di tabel albums, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN
5. Indexing: Membuat idx_tracks_id_album (Hash), pada kolom id_album di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN

#### **(After) Execution Plan**:
Menggunakan index idx_albums_release_date: index search 1x dan mengembalikan 24 rows yang terfilter
<img src="./Query Optimization/screenshot/kasus 1_after.png" alt="Kasus 1 After Optimization" width="100%">

---

### 2. Kasus 2

#### **Deskripsi**:
Mencari total track per album bertipe studio 
yang dirilis oleh group yang berstatus aktif.

#### **(Before) Execution Plan**:
Dominan seq scan, index yang digunakan hanya index primary key
<img src="./Query Optimization/screenshot/kasus 2_before.png" alt="Kasus 2 Before Optimization" width="100%">

#### **Upaya Optimizing**
1. SQL Tuning: Menyederhanakan subquery menjadi join
2. SQL Tuning: Mengubah cartesian (from a, b) menjadi JOIN
3. SQL Tuning: Menghilangkan LOWER
4. SQL Tuning: Mengubah operator LIKE '%...%' menjadi '=' dan tanpa % di depan string
5. Indexing: Membuat idx_groups_status (Hash), pada kolom status di tabel groups, untuk memfilter 'eksak (=)' status
6. Indexing: Membuat idx_albums_type (Hash), pada kolom type di tabel albums, untuk memfilter 'eksak (=)' jenis album
7. Indexing: Membuat idx_tracks_id_album (Hash), pada kolom id_album di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN

#### **(After) Execution Plan**:
Penggunan index idx_album_type: index search 1x dan mengembalikan 75 baris yang terfilter
<img src="./Query Optimization/screenshot/kasus 2_after.png" alt="Kasus 2 After Optimization" width="100%">

---

### 3. Kasus 3: Track dari Group Non-Hiatus yang Dirilis Januari 2018

#### **Deskripsi**:
Mencari daftar track dari group yang BUKAN berstatus 'HIATUS's dan albumnya dirilis pada bulan Januari tahun 2018.

#### **(Before) Execution Plan**:

<img src="./Query Optimization/screenshot/kasus 3_before.png" alt="Kasus 3 Before Optimization" width="100%">

---

#### **Upaya Optimizing**
1. SQL Tuning: Menghapus NOT
2. SQL Tuning: Mengubah operator EXTRACT menjadi perbandingan (>= <=)
3. Indexing: Membuat idx_albums_release_group (Composite B-Tree), pada kolom release_date dan id_group di tabel albums, untuk memfilter 'rentang (>= <=)' tanggal dan 'eksak (=)' Foreign Key saat operasi JOIN
4. Indexing: Membuat idx_tracks_id_album (Hash), pada kolom id_album di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN

#### **(After) Execution Plan**:
Penggunaan index idx_albums_release_group: index search 1x dan mengembalikan 2 baris yang terfilter
<img src="./Query Optimization/screenshot/kasus 3_after.png" alt="Kasus 3 After Optimization" width="100%">

---

## Penggunaan AI

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