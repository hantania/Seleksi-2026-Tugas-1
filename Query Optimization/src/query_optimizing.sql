/* Kasus 1
Mencari daftar track dari album yang dirilis pada tahun 2020 
beserta nama group yang merilis album tersebutS.
Expected output: group_name, album_name, track_title
*/

-- K1: Query Before
EXPLAIN ANALYZE
SELECT 
    (SELECT g.name 
    FROM groups g 
	WHERE g.id_group = a.id_group) AS group_name,
    a.name AS album_name,
    t.title AS track_title
FROM albums a
JOIN tracks t ON a.id_album = t.id_album
WHERE EXTRACT(YEAR FROM a.release_date) = 2020;

-- INDEXING
-- Membuat B-Tree Index, pada kolom release_date, di tabel album, untuk memfilter 'rentang (>= <=)' tanggal
CREATE INDEX idx_albums_release_date ON albums USING btree (release_date);
-- Membuat Hash Index, pada kolom ID_group, di tabel album, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN
CREATE INDEX idx_albums_id_group ON albums USING hash (ID_group);
-- Membuat Hash Index, pada kolom ID_album, di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN
CREATE INDEX idx_tracks_id_album ON tracks USING hash (ID_album);

-- K1: Query After
EXPLAIN ANALYZE
SELECT 
    g.name AS group_name,
    a.name AS album_name,
    t.title AS track_title
FROM albums a
JOIN groups g ON a.id_group = g.id_group
JOIN tracks t ON a.id_album = t.id_album
WHERE a.release_date >= '2020-01-01' 
  AND a.release_date <= '2020-12-31';

/* Kasus 2
Mencari total track per album bertipe studio 
yang dirilis oleh group yang berstatus aktif.
Expected output: group_name, album_name, total_tracks
*/

-- K2: Query Before
EXPLAIN ANALYZE
SELECT 
    g.name AS group_name,
    a.name AS album_name,
    (
        SELECT COUNT(t.title) 
        FROM tracks t 
        WHERE t.id_album = a.id_album
    ) AS total_tracks
FROM groups g, albums a
WHERE g.id_group = a.id_group
AND LOWER(g.status) = 'active'
AND a.type LIKE '%STUDIO%';

-- INDEXING
-- Membuat Hash Index, pada kolom status, di tabel groups, untuk memfilter 'eksak (=)' status
CREATE INDEX idx_groups_status ON groups USING hash (status);
-- Membuat Hash Index, pada kolom type, di tabel album, untuk memfilter 'eksak (=)' jenis album
CREATE INDEX idx_albums_type ON albums USING hash (type);
-- Membuat Hash Index, pada kolom ID_album, di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN & GROUP BY
CREATE INDEX idx_tracks_id_album ON tracks USING hash (ID_album);

--- K2: Query After 
EXPLAIN ANALYZE
SELECT 
    g.name AS group_name,
    a.name AS album_name,
    COUNT(t.title) AS total_tracks
FROM groups g
JOIN albums a ON g.id_group = a.id_group
JOIN tracks t ON a.id_album = t.id_album
WHERE g.status = 'ACTIVE'
AND a.type = 'STUDIO'
GROUP BY a.id_album, g.name, a.name;

/* Kasus 3
Mencari daftar track dari group yang BUKAN berstatus 'HIATUS'
dan albumnya dirilis pada bulan Januari tahun 2018.
Expected output: group_name, album_name, track_title, release_date
*/

-- K3: Query Before
EXPLAIN ANALYZE
SELECT 
    g.name AS group_name,
    a.name AS album_name,
    t.title AS track_title,
    a.release_date
FROM groups g
JOIN albums a ON g.id_group = a.id_group
JOIN tracks t ON a.id_album = t.id_album
WHERE NOT (g.status = 'HIATUS')
  AND EXTRACT(MONTH FROM a.release_date) = 1
  AND EXTRACT(YEAR FROM a.release_date) = 2018;

-- INDEXING
-- Membuat Composite B-Tree Index pada tabel albums (release_date, id_group)
CREATE INDEX idx_albums_release_group ON albums USING btree (release_date, id_group);
-- Membuat Hash Index, pada kolom ID_album, di tabel tracks, untuk memfilter 'eksak (=)' Foreign Key saat operasi JOIN & GROUP BY
CREATE INDEX idx_tracks_id_album ON tracks USING hash (ID_album);

-- K3: Query After 
EXPLAIN ANALYZE
SELECT 
    g.name AS group_name,
    a.name AS album_name,
    t.title AS track_title,
    a.release_date
FROM groups g
JOIN albums a ON g.id_group = a.id_group
JOIN tracks t ON a.id_album = t.id_album
WHERE g.status != 'HIATUS'
  AND a.release_date >= '2018-01-01'
  AND a.release_date <= '2018-01-31';
