import time
import logging
from datetime import datetime
from utils import BASE_URL, get_soup, get_value, save_json, load_json

'''
Fungsi untuk mengambil informasi Label
'''
def scrap_label(batch_name):
    labels = []
    sitemap_label = []

    # Load connector label dari connector
    connector_label = load_json("connector_group_label.json", batch_name, "sitemap")
    count = 0
    scraped = set() # Diperlukan karena slug di connector_label mungkin saja terduplikat (label mengelola beberapa group)

    for l in connector_label:
        slug = l['label_slug']
        if slug in scraped:
            continue
        scraped.add(slug)
        
        url = BASE_URL + slug
        soup_label = get_soup(url)
        if not soup_label:
            continue

        # Scrap Data Label
        container = soup_label.find('div', class_='grid')
        name = soup_label.find('h1').get_text(strip=True)
        founded_year = get_value(container, 'Founded', 'span', 'p')
        founder = get_value(container, 'Founder', 'span', 'p')

        # Masukkan Data Label
        labels.append({
            'name': name,
            'founded_year': founded_year,
            'founder': founder
        })

        # Masukkan Data Sitemap
        sitemap_label.append({
            'label_slug': slug,
            'label_name': name
        })
        logging.info(f"Berhasil mengambil Data Label {name}")
        count += 1
        time.sleep(1)

    logging.info(f"Berhasil mengambil {count} Data Label")

    # Simpan Data Labels
    save_json(labels, "raw_labels.json", batch_name, "raw")
    save_json(sitemap_label, "sitemap_label.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_label(batch_name)