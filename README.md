# Набор из 30 статичных сайтов.

## Шаблоны
| Папка | Язык | Тема / стиль |
|---|---|---|
| 01-en-photo | English | фотостудия, тёмный минимализм |
| 02-pl-coffee | Polski | паларня кофе, тёплый serif |
| 03-nl-arch | Nederlands | архитектурное бюро, белая сетка |
| 04-fr-patisserie | Français | кондитерская, пастельный |
| 05-es-travel | Español | тур-агентство, яркий |
| 06-pt-surf | Português | школа сёрфинга, морской |
| 07-zh-tea | 中文 | чайная, дзен-минимализм |
| 08-ja-ceramics | 日本語 | керамика, ваби-саби |
| 09-de-it | Deutsch | IT-консалтинг, корпоративный |
| 10-it-trattoria | Italiano | траттория, тёплый serif |
| 11-sw-safari | Kiswahili | эко-лодж/сафари, землистый |
| 12-en-saas | English | SaaS-лендинг, градиент |
| 13-fr-vin | Français | винодельня, тёмный бордо |
| 14-es-yoga | Español | йога-студия, спокойный зелёный |
| 15-en-books | English | книжный магазин, литературный |

Каждый шаблон — это папка `templates/<имя>/` с одним самодостаточным `index.html`.

Готово — Caddy отдаёт файлы с диска сразу, перезапуск не нужен.

## Использование скрипта
```bash
bash deploy.sh                # случайный шаблон
bash deploy.sh 07-zh-tea      # конкретный шаблон
bash deploy.sh --list         # список шаблонов
```

## Запуск на сервере

Первый раз — склонировать репозиторий и поставить случайный шаблон:
```bash
git clone https://github.com/vtslynet-cyber/selfsteal-templates.git /opt/selfsteal-templates
bash /opt/selfsteal-templates/deploy.sh
```

Дальше — обновить из git и сразу поставить случайный шаблон (одной командой):
```bash
bash /opt/selfsteal-templates/update.sh
```

Дополнительно:
```bash
bash /opt/selfsteal-templates/update.sh 07-zh-tea     # конкретный шаблон
# автосмена случайного шаблона каждый день в 04:00:
echo '0 4 * * * root /usr/bin/bash /opt/selfsteal-templates/update.sh >/dev/null 2>&1' > /etc/cron.d/selfsteal-rotate
```

Перед каждой заменой текущий сайт сохраняется в `/root/site.bak.<дата>` (хранятся последние 5). Откат:
```bash
rm -rf /var/www/site && mv /root/site.bak.ГГГГММДД-ЧЧММСС /var/www/site
```
> Веб-рут по умолчанию `/var/www/site`; изменить — `WEBROOT=/путь bash deploy.sh`.
