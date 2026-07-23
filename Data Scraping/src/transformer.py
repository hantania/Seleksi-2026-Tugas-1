import greenlet
import logging
import os
import re
from datetime import datetime
from utils import load_json, save_json

NULL_VALUES = {"—", "-", "", "N/A", None}

'''
Generator ID berdasarkan sitemap/connector
'''
def generate_id(items, slug_key, name_key):
    result = []
    seen = set()

    for item in items:
        slug, name = item[slug_key], item[name_key]
        if slug not in seen:
            seen.add(slug)
            result.append({
                "id" : len(seen),
                "name": name,
                "slug": slug
            })
    return result

'''
Generator ID berdasarkan Nama (tanpa slug)
'''
def generate_id_by_name(items, name_key):
    result = []
    seen = set()

    for item in items:
        name = item[name_key]
        if name not in NULL_VALUES and name not in seen:
            seen.add(name)
            result.append({
                "id": len(seen),
                "name": name
            })
    return result


'''
Helper untuk cari atribut pada hasil generator (ID-name-slug)
'''
def get_attribute(data_list, search_key, search_val, return_key):
    for item in data_list:
        if item.get(search_key) == search_val:
            return item.get(return_key)
    return None

'''
Helper untuk cari object
'''
def get_item(data_list, search_key, search_val):
    for item in data_list:
        if item.get(search_key) == search_val:
            return item
    return None

'''
Transformasi untuk Data All Group, Disbanded Group, Hiatus Group
'''
def clean_group_details(raw_groups, ID_GROUP, ID_LABEL, conn_subunit, conn_label):
    all_group = []
    disbanded_group = []
    hiatus_group = []
    
    for item in raw_groups:  
        # Data Inti
        name = item["name"]
        # Cari ID Group berdasarkan nama
        id = get_attribute(ID_GROUP, 'name', name, 'id') 
        if not id:
            continue
        # Ambil other name pertama jika ada
        other_name = item['other_name']
        if other_name not in NULL_VALUES: 
            other_name_clean = other_name.split(",")[0].strip() 
        else:
            other_name_clean = None            
        status = item['status'].strip().upper()  # Ubah ke uppercase
        debut_date = item['debut_date']
        # Ubah generation ke int
        generation = item['generation']
        if generation not in NULL_VALUES:
            generation = int(generation)
        else:
            generation = None
        # Cari ID Parent Group 
        group_slug = get_attribute(ID_GROUP, 'name', name, 'slug') # Cari group_slug berdasarkan nama group di ID_GROUP
        parent_slug = get_attribute(conn_subunit, 'sub_slug', group_slug, 'parent_slug') # Gunakan group_slug (as sub_slug) untuk mencari parent_slug di conn_subunit
        id_parent_group = get_attribute(ID_GROUP, 'slug', parent_slug, 'id') # Gunakan parent_slug untuk mencari ID parent group di ID_GROUP
        # Cari ID Label
        label_slug = get_attribute(conn_label, 'group_slug', group_slug, 'label_slug') # Cari label_slug berdasarkan group_slug di conn_label
        if not label_slug and parent_slug: # Agar SubUnit bisa dapat ID Label dari Parent Group
            label_slug = get_attribute(conn_label, 'group_slug', parent_slug, 'label_slug')
        id_label = get_attribute(ID_LABEL, 'slug', label_slug, 'id') # Gunakan label_slug untuk mencari ID label di ID_LABEL

        # Data tambahan untuk group disbanded dan hiatus
        active_years = item['active_years']
        if active_years not in NULL_VALUES:
            if "-" in active_years:
                # Ambil tahun akhir setelah "-"
                disband_year = active_years.split("-")[-1].strip()[-4:] 
            if "hiatus" in active_years:
                # Ambil tahun awal setelah kata "hiatus:"
                hiatus_year = active_years.split("hiatus:")[-1].strip()[:4] 

        # Masukkan data inti group
        all_group.append({
            'id_group': id,
            'id_label': id_label,
            'name': name,
            'other_name': other_name_clean,
            'status': status,
            'debut_date': debut_date,
            'generation': generation,
            'id_parent_group': id_parent_group
        })

        # Masukkan data tambahan jika group disbanded/hiatus
        if status == "DISBANDED":
            disbanded_group.append({
                'id_group': id,
                'disband_year': disband_year
            })
        if status == "HIATUS":
            hiatus_group.append({
                'id_group': id,
                'hiatus_year': hiatus_year
            })

    return all_group, disbanded_group, hiatus_group

'''
Transformasi untuk Data Group Metrics
'''
def clean_group_metrics(raw_group_ranks, raw_scores, ID_GROUP):
    group_metrics = []

    for item in raw_group_ranks:
        name = item['name']
        # Cari ID Group berdasarkan nama
        id = get_attribute(ID_GROUP, 'name', name, 'id')
        if not id:
            continue
        # Cari data score berdasarkan nama
        score_item = get_item(raw_scores, 'group_name', name)
        if not score_item:
            continue
        scraped_at = item['scraped_at']
        # Ubah masing2 metric ke integer
        rank = int(item['rank']) 
        total_bias_votes = int(item['total_bias_votes'].replace(',', ''))
        stage = int(score_item['stage_score'])
        artistry = int(score_item['artistry_score'])
        vocals = int(score_item['vocal_score'])
        visual = int(score_item['visual_score'])
        dance = int(score_item['dance_score'])
        
        # Masukkan Data Group Metrics
        group_metrics.append({
            'id_group': id,
            'scraped_at': scraped_at,
            'rank': rank,
            'total_bias_votes': total_bias_votes,
            'dance_score': dance,
            'vocal_score': vocals,
            'stage_score': stage,
            'artistry_score': artistry,
            'visual_score': visual
        })
    return group_metrics

'''
Transformasi untuk Data Label
'''
def clean_labels(raw_labels, ID_LABEL):
    labels = []
    
    for item in raw_labels:
        name = item['name']
        # Cari ID Label berdasarkan nama
        id = get_attribute(ID_LABEL, 'name', name, 'id')
        if not id:
            continue 
        # Ubah founded_year ke integer
        found_val = item['founded_year']
        if found_val not in NULL_VALUES:
            found_date = int(found_val) 
        else:
            found_date = None
        # Ambil founder pertama jika ada
        founder = item['founder']
        if founder not in NULL_VALUES:
            founder = founder.split(",")[0].strip()
        else:
            founder = None

        # Masukkan Data Label
        labels.append({
            'id_label': id,
            'name': name,
            'founded_year': found_date,
            'founder': founder
        })

    return labels

'''
Transformasi untuk Data Album
'''
def clean_albums(raw_albums, ID_ALBUM, ID_GROUP, conn_album):
    albums = []

    for item, album_info in zip(raw_albums, ID_ALBUM):
        name = item['name']
        id = album_info['id']
        album_slug = album_info['slug']
        if not id:
            continue 
        # Ubah album_type ke uppercase
        tipe = item['type']
        if tipe not in NULL_VALUES:
            tipe = tipe.strip().upper()
        else:
            tipe = None
        # Ubah release_date ke format "YYYY-MM-DD"
        release_date = None
        date = item['release_date']
        if date not in NULL_VALUES:
            date = str(date).strip()[:10]
            if re.match(r'^\d{4}-\d{2}-\d{2}$', date): 
                release_date = date
        # Ambil language pertama
        language = item['language']
        if language not in NULL_VALUES:
            language = language.split(',')[0].strip()
        else:
            language = None
        # Deskripsi album
        desc = item['description']
        if desc not in NULL_VALUES:
            desc = desc.strip()
        else:
            desc = None
        # Cari ID Group yang merilis album
        group_slug = get_attribute(conn_album, 'album_slug', album_slug, 'group_slug')
        id_group = get_attribute(ID_GROUP, 'slug', group_slug, 'id') 
        
        # Masukkan Data Album
        albums.append({
            'id_album': id,
            'id_group': id_group,
            'name': name,
            'type': tipe,
            'release_date': release_date,
            'language': language,
            'description': desc
        })
    return albums

'''
Transformasi untuk Data Track
'''
def clean_tracks(conn_track, ID_ALBUM):
    tracks = []
    
    for item in conn_track:
        # Cari ID Album berdasarkan Slug
        album_slug = item["album_slug"]
        id_album = get_attribute(ID_ALBUM, "slug", album_slug, "id")
        if not id_album:
            continue
        # Ambil Nama Track
        track = item["title"]
        if track not in NULL_VALUES:
            track = track.strip()
        else:
            track = None

        # Masukkan Data Track
        tracks.append({
            "id_album": id_album,
            "track": track
        })
    return tracks

'''
Transformasi untuk Data Fandom dan Fandom Colors
'''
def clean_fandoms(raw_fandoms, ID_GROUP, ID_FANDOM):
    fandoms = []
    fandom_colors = []
    
    for item in raw_fandoms:
        # Cari ID Group berdasarkan nama
        group_name = item["group_name"]
        group_id = get_attribute(ID_GROUP, "name", group_name, "id")
        if not group_id:
            continue
        # Cari ID Fandom berdasarkan nama
        fandom_name = item["fandom_name"]
        id_fandom = get_attribute(ID_FANDOM, "name", fandom_name, "id")
        if not id_fandom:
            continue 

        # Masukkan Data Fandom
        fandoms.append({
            'id_fandom': id_fandom,
            'id_group': group_id,
            'fandom_name': fandom_name
        })

        # Data Warna Fandom
        colors = item.get("color_identity") or []
        if isinstance(colors, str):
            colors = [c.strip() for c in colors.split(",") if c.strip()]
        for color in colors:
            if color not in NULL_VALUES:
                # Masukkan Data Warna Fandom
                fandom_colors.append({
                    'id_fandom': id_fandom,
                    'color_identity': color.strip()
                })
           
    return fandoms, fandom_colors
    
'''
Transformasi untuk Data Idol
'''    
def clean_idols(raw_idols, ID_IDOL):
    idols = []
    
    for item, idol_info in zip(raw_idols, ID_IDOL):
        stage_name = item["stage_name"]
        full_name = item["full_name"]
        id_idol = idol_info["id"]
        if not id_idol:
            continue
        # Ubah Birthday ke format "YYYY-MM-DD"
        birthday = None
        b_day = item["birthday"]
        if b_day not in NULL_VALUES:
            date = str(b_day).strip()[:10]
            if re.match(r'^\d{4}-\d{2}-\d{2}$', date):
                birthday = date
        # Split birthplace menjadi birth_adm_area dan birth_country
        birthplace = item["birthplace"]
        birth_adm_area = None #Inisialisasi
        birth_country = None #Inisialisasi
        if birthplace not in NULL_VALUES:
            parts = [p.strip() for p in birthplace.split(",") if p.strip()]
            if len(parts) >= 1: 
                # Ambil kata terakhir untuk country
                birth_country   = parts[-1] 
            if len(parts) >= 2:
                # Ambil kata kedua terakhir untuk administrative area
                birth_adm_area  = parts[-2]
        # Formatting height
        height = item["height"]
        if height not in NULL_VALUES:
            # Ambil 3 karakter (hapus cm), ubah ke int
            height = int(height.strip()[:3])
        else:
            height = None

        # Masukkan Data Idol
        idols.append({
            "id_idol": id_idol,
            "stage_name": stage_name,
            "full_name": full_name,
            "birthday": birthday,
            "birth_adm_area": birth_adm_area,
            "birth_country": birth_country,
            "height": height
        })
    return idols

'''
Transformasi untuk Data Group Idols
'''
def clean_group_idols(conn_idol, ID_GROUP, ID_IDOL):
    group_idols = []
        
    for item in conn_idol:
        # Cari ID Group berdasarkan group_slug
        group_slug = item["group_slug"]
        id_group = get_attribute(ID_GROUP, "slug", group_slug, "id")
        if not id_group:
            continue
        # Cari ID Idol berdasarkan member_slug
        member_slug = item["member_slug"]
        id_idol = get_attribute(ID_IDOL, "slug", member_slug, "id")
        if not id_idol:
            continue
        # Ambil role
        role = item["role"]
        fix_roles = set() # Untuk menyimpan role yang sudah difix
        if role not in NULL_VALUES:
            # Pisahkan berdasarkan koma dan ubah ke uppercase
            roles = [r.strip().upper() for r in role.split(",") if r.strip()]
            for r in roles:
                matched = False
                for expected_role in ["RAPPER", "VOCALIST", "LEADER", "DANCER", "VISUAL"]:
                    if expected_role in r:
                        fix_roles.add(expected_role)
                        matched = True
                        break
                if not matched: # Jika tidak ada expected_role yang cocok
                    fix_roles.add("OTHERS")
        # Jika fix_roles kosong anggap "OTHERS"
        if not fix_roles:
            fix_roles.add("OTHERS")

        # Masukkan data group_idols
        for role in sorted(fix_roles):
            group_idols.append({
                "id_group": id_group,
                "id_idol": id_idol,
                "role": role
            })
    return group_idols

'''
Mengintegrasikan semua transformasi
'''
def transform(batch_name):
    logging.info(f"Memulai transformasi data untuk batch: {batch_name}")

    # Load sitemap
    sitemap_idol = load_json("sitemap_idol.json", batch_name, "sitemap")
    sitemap_label = load_json("sitemap_label.json", batch_name, "sitemap")
    sitemap_group = load_json("sitemap_group.json", batch_name, "sitemap")
    sitemap_subunit = load_json("sitemap_sub_unit.json", batch_name, "sitemap")
    sitemap_album = load_json("sitemap_album.json", batch_name, "sitemap")
    # Gabungkan sitemap group dan sub unit
    sitemap_group_unit = []
    for g in sitemap_group:
        sitemap_group_unit.append({"slug": g["group_slug"], "name": g["group_name"]})
    for u in sitemap_subunit:
        sitemap_group_unit.append({"slug": u["unit_slug"], "name": u["unit_name"]})


    # Load connectors
    conn_subunit = load_json("connector_group_subunit.json", batch_name, "sitemap")
    conn_label = load_json("connector_group_label.json", batch_name, "sitemap")
    conn_idol = load_json("connector_group_idol.json", batch_name, "sitemap")
    conn_album = load_json("connector_group_album.json", batch_name, "sitemap")
    conn_track = load_json("connector_album_track.json", batch_name, "sitemap")

    # Load raw data
    raw_fandoms = load_json("raw_fandoms.json", batch_name, "raw")
    raw_groups = load_json("raw_group_detail.json", batch_name, "raw") + load_json("raw_sub_unit.json", batch_name, "raw")
    raw_scores = load_json("raw_group_score.json", batch_name, "raw")
    raw_group_ranks = load_json("raw_group_rank.json", batch_name, "raw")
    raw_idols = load_json("raw_idols.json", batch_name, "raw")
    raw_labels = load_json("raw_labels.json", batch_name, "raw")
    raw_albums = load_json("raw_albums.json", batch_name, "raw")
    
    # Generate ID
    ID_GROUP = generate_id(sitemap_group_unit, "slug", "name")
    ID_IDOL = generate_id(sitemap_idol, "idol_slug", "idol_name")
    ID_LABEL = generate_id(sitemap_label, "label_slug", "label_name")
    ID_ALBUM = generate_id(sitemap_album, "album_slug", "album_name")
    ID_FANDOM = generate_id_by_name(raw_fandoms, "fandom_name")

    # Transform Data
    groups, disbanded, hiatus = clean_group_details(raw_groups, ID_GROUP, ID_LABEL, conn_subunit, conn_label)
    save_json(groups, "groups.json", batch_name, "clean")
    save_json(disbanded, "group_disbanded.json", batch_name, "clean")
    save_json(hiatus, "group_hiatus.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Group")

    group_metrics = clean_group_metrics(raw_group_ranks, raw_scores, ID_GROUP)
    save_json(group_metrics, "group_metrics.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Group Metrics")

    labels = clean_labels(raw_labels, ID_LABEL)
    save_json(labels, "labels.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Label")

    albums = clean_albums(raw_albums, ID_ALBUM, ID_GROUP, conn_album)
    save_json(albums, "albums.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Album")

    tracks = clean_tracks(conn_track, ID_ALBUM)
    save_json(tracks, "album_tracks.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Album Track")

    fandoms, fandom_colors = clean_fandoms(raw_fandoms, ID_GROUP, ID_FANDOM)
    save_json(fandoms, "fandoms.json", batch_name, "clean")
    save_json(fandom_colors, "fandom_colors.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Fandom")

    idols = clean_idols(raw_idols, ID_IDOL)
    save_json(idols, "idols.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Idol")

    group_idols = clean_group_idols(conn_idol, ID_GROUP, ID_IDOL)
    save_json(group_idols, "group_idols.json", batch_name, "clean")
    logging.info("Berhasil Membersihkan Data Group Idols")

    logging.info(f"Seluruh Data Batch {batch_name} Berhasil di-Transformasi!")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    transform(batch_name)
