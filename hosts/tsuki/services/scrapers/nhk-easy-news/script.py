from pathlib import Path
from urllib.parse import urlparse
from textwrap import dedent, indent
import os
import json

import requests
import wget


BASE_URL = "https://www3.nhk.or.jp/news/easy"


def url_filename(url) -> str:
    parsed_url = urlparse(url)
    path = parsed_url.path
    return Path(path).name


def try_download(url, path) -> str | None:
    try:
        wget.download(url, out=str(path))
    except Exception as err:
        if path.exists():
            os.remove(path)
        return err


def download_article(article, dir_path):
    news_id = article['news_id']
    article_path = dir_path / news_id
    if not article_path.exists():
        print(f"New article with ID: {news_id}")
        os.mkdir(article_path)

    index_path = article_path / 'index.html'
    if not index_path.exists():
        print("  Downloading article")
        err = try_download(article['news_web_url'], index_path)
        if err is not None:
            print(dedent(f'''
            Failed to download article {news_id}:
              {article['news_web_url']}
            {indent(str(err), '  ')}
            '''))
            return

    info_path = article_path / 'info.json'
    if not info_path.exists():
        print("  Exporting metadata")
        with open(info_path, 'w') as file:
            json.dump(article, file)

    for toggle, url_attr in (
        ('has_news_web_image', 'news_web_image_uri'),
        # ('has_news_web_movie', 'news_web_movie_uri'),
        # ('has_news_easy_image', 'news_easy_image_uri'),
        # ('has_news_easy_movie', 'news_easy_movie_uri'),
        # ('has_news_easy_voice', 'news_easy_voice_uri'),
    ):
        if not article[toggle]:
            continue

        url = article[url_attr]
        # if not url.startswith('http'):
        #     url = BASE_URL + '/' + url

        path = article_path / url_filename(url)
        if path.exists():
            continue

        print(f'  Downloading supplementary material: {url_filename(url)}')

        err = try_download(url, path)
        if err is not None:
            print(dedent(f'''
            Failed to download supplementary material for article {news_id}:
              {url}
            {indent(str(err), '  ')}
            '''))


def main():
    print("Starting nhk easy news scraper")
    print()
    print("Fetching article index...")
    nhkjson = requests.get(BASE_URL + '/news-list.json').json()
    base_dir = Path(".").resolve()
    print('Got article index')

    if not (base_dir / 'articles').exists():
        os.mkdir(base_dir / 'articles')

    for date, articlelist in nhkjson[0].items():
        date_dir = base_dir / 'articles' / date
        if not date_dir.exists():
            print(f"Found new articles for {date}")
            os.mkdir(date_dir)

        for article in articlelist:
            download_article(article, date_dir)


if __name__ == '__main__':
    main()

