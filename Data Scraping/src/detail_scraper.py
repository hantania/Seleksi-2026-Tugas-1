import os
import logging
from datetime import datetime
from dotenv import load_dotenv
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright
from utils import BASE_URL, get_value, get_value2, get_value3, get_slug, save_json, load_json, ROOT

load_dotenv(os.path.join(ROOT, ".env"))
USERNAME = os.getenv("KPOPPING_USERNAME")
PASSWORD = os.getenv("KPOPPING_PASSWORD")

'''
Fungsi untuk mengambil informasi detail mengenai:
- Entitas Group (Detail)
- Skor Group    (Detail)
- Fandom        (Detail)
- Idol          (Connector + Role)
- Album         (Connector)
- Sub-unit      (Connector)
'''
def scrap_detail(batch_name):
    groups = []
    group_score = []
    fandoms = []

    connector_group_idol = []
    connector_group_label = []    
    connector_group_album = []
    connector_group_subunit = []

    # Load slug group dari sitemap_group.json
    sitemap_group = load_json("sitemap_group.json", batch_name, "sitemap")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        page.goto("https://kpopping.com/login")

        # Login ke Website Kpopping
        page.locator('input[placeholder="email or @username"]').fill(USERNAME)
        page.locator('input[type="password"]').fill(PASSWORD)
        page.locator('button[type="submit"]').click()
        page.wait_for_url("https://kpopping.com/")

        # Iterasi untuk setiap group
        for g in sitemap_group:
            slug = g['group_slug']
            url = BASE_URL + slug

            page.goto(url, wait_until="domcontentloaded")
            page.locator("h3:has-text('Skill Pentagon')").scroll_into_view_if_needed()
            page.locator("#discography").scroll_into_view_if_needed()
            page.wait_for_timeout(2500)
            html = page.content()
            soup_group = BeautifulSoup(html, "html.parser")
            logging.info(f"Memuat URL: {url}")

            # Scrap Data Group Detail
            container_detail = soup_group.find('div', id='profile-gate')
            name = g['group_name']
            other_name = get_value(container_detail, 'Other Names', 'p', 'p')
            status = get_value3(container_detail, 'lucide-star', 'svg', 'span')
            debut_date = get_value(container_detail, 'Debut', 'p', 'p')
            generation = get_slug(soup_group, "/categories/groups/generation").split("generation-")[-1]
            active_year = get_value(container_detail, 'Active Years', 'p', 'p')

            # Masukkan Data Group
            groups.append({
                'name': name,
                'other_name': other_name,
                'status': status,
                'debut_date': debut_date,
                'generation': generation,
                'active_years': active_year,
            })

            # Masukkan Data Connector Group - Label
            label_slug = get_slug(container_detail, "/profiles/company")  
            connector_group_label.append({
                'label_slug': label_slug,
                'group_slug': slug
            })                
            logging.info(f"Berhasil mengambil Data Group {name}")

            # Scrap Data Skor Group
            stage = get_value2(soup_group, 'STAGE', 'div', 'div')
            artistry = get_value2(soup_group, 'ARTISTRY', 'div', 'div')
            vocals = get_value2(soup_group, 'VOCALS', 'div', 'div')
            visual = get_value2(soup_group, 'VISUAL', 'div', 'div')
            dance = get_value2(soup_group, 'DANCE', 'div', 'div')
            group_score.append({
                "group_name": name,
                "dance_score": dance,
                "vocal_score": vocals,
                "stage_score": stage,
                "artistry_score": artistry,
                "visual_score": visual
            })
            logging.info(f"Berhasil mengambil Data Skor Group {name}") 

            # Scrap Data Fandom Group
            fandom_name = get_value(container_detail, 'Fandom', 'p', 'p')
            colors_div = container_detail.find('p', string='Fandom Colors')
            color_identity = [c.get_text(strip=True) for c in colors_div.find_next('div').find_all('div', recursive=False)] if colors_div else None
            fandoms.append({
                "group_name": name,
                "fandom_name": fandom_name,
                "color_identity": color_identity,
            })
            logging.info(f"Berhasil mengambil Data Fandom Group {name}")
            
            # Scrap Data Idol (Connector + Role)
            container_idol = soup_group.find('div', class_="GroupMembers_membersPanel__m77yg")
            if container_idol:
                idol_card = container_idol.find_all('div', class_="GroupMembers_memberCard__ncAF2")
                for i in idol_card:
                    member_slug = i.find('a', class_="GroupMembers_memberLink__ely_L").get('href')
                    role = i.find('p', class_='GroupMembers_memberPosition__PuTmn').get_text(strip=True)
                    connector_group_idol.append({
                        'group_slug': slug,
                        'member_slug': member_slug,
                        "role": role,
                    })
                logging.info(f"Berhasil mengambil Data Role Idol di Group {name}")

            # Scrap Data Album (Connector)
            container_album = soup_group.find("div", id="discography")
            if container_album:
                for a in container_album.find_all("a", class_="group", href=True):
                    connector_group_album.append({
                        "group_slug": slug,
                        "album_slug": a["href"]
                    })
                logging.info(f"Berhasil mengambil Connector Group - Album")
            
            # Scrap Data Group Sub-unit (Connector)
            container_sub_unit = soup_group.find('h3', string="Sub-units")
            if container_sub_unit:
                card_sub_unit = container_sub_unit.find_next('div').find_all('a')
                for sub_unit in card_sub_unit:
                    slug_sub_unit = sub_unit.get('href')
                    connector_group_subunit.append({
                        "parent_slug": slug,
                        "sub_slug": slug_sub_unit 
                    })
                logging.info(f"Berhasil mengambil Connector Group - Sub-unit")
                
        browser.close()

    '''Simpan seluruh Data dan Connector (U/Next scrap)'''
    save_json(groups, "raw_group_detail.json", batch_name, "raw") 
    save_json(group_score, "raw_group_score.json", batch_name, "raw")   
    save_json(fandoms, "raw_fandoms.json", batch_name, "raw")   
    save_json(connector_group_idol, "connector_group_idol.json", batch_name, "sitemap")
    save_json(connector_group_label, "connector_group_label.json", batch_name, "sitemap")
    save_json(connector_group_album, "connector_group_album.json", batch_name, "sitemap")
    save_json(connector_group_subunit, "connector_group_subunit.json", batch_name, "sitemap")

if __name__ == "__main__":
    batch_name = f"batch-{datetime.now().strftime('%Y-%m-%d')}"
    scrap_detail(batch_name=batch_name)