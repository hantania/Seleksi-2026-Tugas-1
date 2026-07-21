import logging
from datetime import datetime
from utils import BASE_URL, get_soup, save_json

'''Fungsi untuk mengambil Data Group (Rank + Total Votes only)'''
def scrap_group_rank(batch_name):
    group = []         # Simpan data Rank Group
    sitemap_group = [] # Simpan slug untuk scrap detail

    rank_url = BASE_URL + "/categories/groups/ranking"
    soup_mv = get_soup(rank_url)
    if not soup_mv:
        logging.error("Gagal mendapatkan halaman ranking group")
        return

    scraped_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Ambil row masing2 Group
    rows = soup_mv.select('table > tbody > tr')
    count = 0
    # Iterasi untuk setiap Group
    for row in rows:
        cols = row.select('td')

        # Scrap Data Rank Group
        name = cols[1].find_next('p').get_text()
        rank = cols[0].get_text(strip=True)
        total_bias_votes = cols[2].get_text(strip=True)

        # Scrap Slug
        group_slug = cols[1].select_one("a")["href"] 

        # Masukkan Data Group
        group.append({
            'name' : name,
            'scraped_at': scraped_at,
            'rank' : rank,
            'total_bias_votes': total_bias_votes
        })

        # Masukkan Data Slug ke Sitemap
        sitemap_group.append({
            'group_slug' : group_slug,
            'group_name' : name
        })
        count += 1

    logging.info(f"Berhasil mengambil {count} data K-Pop Group terpopuler")

    # Simpan Data Rank Group + Sitemap Group (U/Next scrap)
    save_json(group, "raw_group_rank.json", batch_name, "raw")
    save_json(sitemap_group, "sitemap_group.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_group_rank(batch_name)


