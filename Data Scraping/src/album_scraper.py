import time
import logging
from datetime import datetime
from utils import BASE_URL, get_soup, get_value, save_json, load_json

'''
Fungsi untuk mengambil informasi Album beserta Track yang ada di dalamnya
- Album (Detail)
- Track (Connector + Title)
'''
def scrap_album(batch_name):
    albums = []
    sitemap_album = []
    connector_album_tracks = []

    # Load connector album dari connector_group_album.json menggunakan load_json helper
    connector_album = load_json("connector_group_album.json", batch_name, "sitemap")

    count = 0
    scraped = set()

    # Iterasi untuk setiap Album
    for a in connector_album:
        slug = a['album_slug']
        if slug in scraped:
            continue
        scraped.add(slug)

        url = BASE_URL + slug
        soup_album = get_soup(url)
        if not soup_album:
            logging.error(f"Gagal memuat soup untuk URL: {url}")
            continue

        # Scrap Data Album
        name = soup_album.find('h1').get_text(strip=True)
        tipe = get_value(soup_album, 'Type', 'p', 'p')
        release_date = get_value(soup_album, 'Release Date', 'p', 'p')
        language = get_value(soup_album, 'Languages', 'p', 'p')
        description = get_value(soup_album, 'Description', 'p', 'p')

        # Masukkan Data Album
        albums.append({
            'album_slug': slug,
            'name': name,
            'type': tipe,
            'release_date': release_date,
            'language': language,
            'description': description
        })

        # Masukkan Sitemap
        sitemap_album.append({
            'album_slug': slug,
            'album_name': name
        })
        logging.info(f"Berhasil mengambil Data Album {name}")
        
        # Scrap Data Track
        container = soup_album.find('h3', string='Track List').find_next('div')
        if container:
            card_track = container.find_all('div', style="flex:1;min-width:0") 
            for c in card_track: 
                title = c.find_next('p').get_text(strip=True)
                connector_album_tracks.append({
                    'album_slug': slug,
                    'title': title
                })
            logging.info(f"Berhasil mengambil Data Lagu dari Album {name}")
      
        count += 1
        time.sleep(1)

    logging.info(f"Berhasil mengambil {count} Data Album")

    # Simpan Data Album dan Track
    save_json(albums, "raw_albums.json", batch_name, "raw")
    save_json(sitemap_album, "sitemap_album.json", batch_name, "sitemap")
    save_json(connector_album_tracks, "connector_album_track.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_album(batch_name=batch_name)