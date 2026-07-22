import logging
import json
import requests
import os
from bs4 import BeautifulSoup

import sys

'''
Berisi helper global yang digunakan oleh scraper
'''
BASE_URL = "https://kpopping.com"
HEADERS  = {"user-agent": "Mozilla/5.0; (Windows NT 10.0; Win64; x64)"}
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

'''
Konfigurasi Logger
'''
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(ROOT, "Data Scraping", "scrap_log.txt"), encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

'''
Helper untuk request HTML
'''
def get_soup(url):
    try:
        logging.info(f"Memuat URL: {url}")
        response = requests.get(url, headers=HEADERS)
        response.raise_for_status()
        logging.info(f"Berhasil mengambil konten dari URL: {url}")
        return BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        logging.error(f"Gagal memuat URL: {url} - {e}")
        return None

'''
Helper untuk mengambil value berdasarkan string label
*Disesuaikan dengan pola HTML yang ada di web Kpopping
'''
def get_value(soup, string_label, tag1, tag2):
    node = soup.find(tag1, string=string_label)
    if node:
        value = node.find_next(tag2).get_text(strip=True)
        return value
    return None

'''
Helper untuk mengambil value berdasarkan string label (versi 2)
*Disesuaikan dengan pola HTML yang ada di web Kpopping
'''
def get_value2(soup, string_label, tag1, tag2):
    node = soup.find(tag1, string=string_label)
    if node:
        value = node.find_previous(tag2).get_text(strip=True)
        return value
    return None

'''Helper untuk mengambil value (versi 3)'''
def get_value3(soup, class_name, tag1, tag2):
    node = soup.find(tag1, class_=class_name)
    if node:
        value = node.find_next(tag2).get_text(strip=True)
        return value
    return None

'''Helper untuk mengambil slug yang akan menjadi connector ke entitas lain'''
def get_slug(soup, rgx):
    element = soup.select_one(f'a[href*="{rgx}"]')
    if element:
        value = element.get('href')
        return value 
    return None

'''Helper untuk save file json'''
def save_json(data, filename, batch_name, category):
    target_dir = os.path.join(ROOT, "Data Scraping", "data", batch_name, category)
    os.makedirs(target_dir, exist_ok=True)
    
    path = os.path.join(target_dir, filename)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    logging.info(f"Data berhasil disimpan dalam file: {path}")

'''Helper untuk load file json'''
def load_json(filename, batch_name, category):
    path = os.path.join(ROOT, "Data Scraping", "data", batch_name, category, filename)    
    if not os.path.exists(path):
        logging.warning(f"File JSON tidak ditemukan: {path}")
        return []
        
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)



