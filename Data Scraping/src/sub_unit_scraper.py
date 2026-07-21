import os
import time
import logging
from datetime import datetime
from utils import BASE_URL, get_soup,get_value, get_value2, get_value3, get_slug, save_json, load_json, ROOT

'''
Fungsi untuk mengambil informasi Sub-Units
'''
def scrap_sub_unit(batch_name):
    sub_units = []
    sitemap_sub_unit = []

    # Load data connector dan sitemap 
    connector_sub_unit = load_json("connector_group_subunit.json", batch_name, "sitemap")
    sitemap_group = load_json("sitemap_group.json", batch_name, "sitemap")

    groups_slug = {group["group_slug"] for group in sitemap_group} if sitemap_group else set()

    count = 0
    # Iterasi untuk setiap Sub-Units
    for u in connector_sub_unit:
        slug = u['sub_slug']
        if slug in groups_slug: # Sudah pernah discrap, pass
            continue

        url = BASE_URL + slug
        soup_sub_unit = get_soup(url)
        if not soup_sub_unit:
            continue

        # Scrap Data Sub-Unit berdasarkan container
        container_detail = soup_sub_unit.find('div', id='profile-gate')
        name = soup_sub_unit.find('h1').get_text(strip=True)
        other_name = get_value(container_detail, 'Other Names', 'p', 'p')
        status = get_value3(container_detail, 'lucide-star', 'svg', 'span')
        debut_date = get_value(container_detail, 'Debut', 'p', 'p')
        generation = get_slug(soup_sub_unit, "/categories/groups/generation").split("generation-")[-1]
        active_year = get_value(container_detail, 'Active Years', 'p', 'p')

        # Masukkan Data Sub-Units
        sub_units.append({
            'name': name,
            'other_name': other_name,
            'status': status,
            'debut_date': debut_date,
            'generation' : generation,
            'active_years': active_year,
        })   
        logging.info(f"Berhasil mengambil Data dari Sub Unit {name}")

        # Masukkan Sitemap
        sitemap_sub_unit.append({
            'unit_slug': slug,
            'unit_name': name
        })

        count += 1
        time.sleep(1)     
        
    logging.info(f"Berhasil mengambil {count} Data Sub-Units")

    # Save Data Sub-Units 
    save_json(sub_units, "raw_sub_unit.json", batch_name, "raw")
    save_json(sitemap_sub_unit, "sitemap_sub_unit.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_sub_unit(batch_name)