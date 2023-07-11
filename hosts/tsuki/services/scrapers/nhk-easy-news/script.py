from pathlib import Path
import os

import requests
import wget


def main():
    nhkjson = requests.get(
        'http://www3.nhk.or.jp/news/easy/news-list.json').json()
    base_dir = Path(".").resolve()

    if not (base_dir / 'articles').exists():
        os.mkdir(base_dir / 'articles')

    for key, value in nhkjson[0].items():
        for x in value:
            news_id = x['news_id']
            path = base_dir / f'articles/nhkeasy_{news_id}.html'

            if path.exists():
                # This means that the article has already been downloaded.
                # Skip and continue
                continue

            print(f"New article with ID: {news_id}")
            try:
                nhkurl = x['news_web_url']
                wget.download(nhkurl, out=str(path))
                print("Successful download of article ID: " + x['news_id'])
            except Exception as err:
                if path.exists():
                    os.remove(path)
                print("Failed to download article ID: " + x['news_id'])
                print(err)


if __name__ == '__main__':
    main()

