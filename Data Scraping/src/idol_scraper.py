import time
import logging
from datetime import datetime
from utils import BASE_URL, get_soup, get_value, save_json, load_json

'''
Fungsi untuk mengambil informasi Idol
'''
def scrap_idol(batch_name):
    idols = []
    sitemap_idol = []

    # Load data connector idol
    connector_idol = load_json("connector_group_idol.json", batch_name, "sitemap")
    
    count = 0
    scraped = set() # Diperlukan karena slug di connector_idol mungkin saja terduplikat

    # Iterasi untuk setiap Idol
    for i in connector_idol:
        slug = i['member_slug']
        if slug in scraped:
            continue
        scraped.add(slug)

        url = BASE_URL + slug
        soup_idol = get_soup(url)
        if not soup_idol:
            continue

        # Scrap Data Idol
        stage_name = soup_idol.find("h1").get_text(strip=True)
        full_name = soup_idol.find("h1").find_next('p').find_next('p').get_text(strip=True)
        birthday = get_value(soup_idol, "Birthday", "p", "p")
        birthplace = get_value(soup_idol, "Birthplace", "span", "span")
        height = get_value(soup_idol, "Height", "p", "p") 

        # Masukkan Data Idol
        idols.append({
            'idol_slug': slug,
            'stage_name': stage_name,
            'full_name': full_name,
            'birthday': birthday,
            'birthplace': birthplace,
            'height': height
        })

        # Masukkan Sitemap
        sitemap_idol.append({
            'idol_slug': slug,
            'idol_name': full_name
        })
        logging.info( f"Berhasil mengambil Data Idol dengan nama {full_name}")

        count += 1
        time.sleep(1)

    logging.info(f"Berhasil mengambil {count} Data Idol")
    
    # Save Data Idols
    save_json(idols, "raw_idols.json", batch_name, "raw")
    save_json(sitemap_idol, "sitemap_idol.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_idol(batch_name=batch_name)