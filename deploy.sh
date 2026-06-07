#!/usr/bin/env bash
# selfsteal template deployer
# Picks a RANDOM static template (or a named one) and installs it into the
# Caddy webroot used by the Reality "selfsteal" decoy site.
set -euo pipefail

WEBROOT="${WEBROOT:-/var/www/site}"     # change with: WEBROOT=/path bash deploy.sh
KEEP_BACKUPS="${KEEP_BACKUPS:-5}"        # how many /root/site.bak.* to keep

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TPL_DIR="$SCRIPT_DIR/templates"

# colors (disabled when not a TTY)
if [ -t 1 ]; then
  C_OK=$'\033[1;32m'; C_INFO=$'\033[1;36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_OK=""; C_INFO=""; C_DIM=""; C_RST=""
fi

# human-readable description per template name
describe(){
  case "$1" in
    01-en-photo)      echo "English  · фотостудия, тёмный минимализм" ;;
    02-pl-coffee)     echo "Polski   · паларня кофе, тёплый serif" ;;
    03-nl-arch)       echo "Nederlands · архитектурное бюро, белая сетка" ;;
    04-fr-patisserie) echo "Français · кондитерская, пастельный" ;;
    05-es-travel)     echo "Español  · тур-агентство, яркий" ;;
    06-pt-surf)       echo "Português · школа сёрфинга, морской" ;;
    07-zh-tea)        echo "中文     · чайная, дзен-минимализм" ;;
    08-ja-ceramics)   echo "日本語   · керамика, ваби-саби" ;;
    09-de-it)         echo "Deutsch  · IT-консалтинг, корпоративный" ;;
    10-it-trattoria)  echo "Italiano · траттория, тёплый serif" ;;
    11-sw-safari)     echo "Kiswahili · эко-лодж/сафари, землистый" ;;
    12-en-saas)       echo "English  · SaaS-лендинг, градиент" ;;
    13-fr-vin)        echo "Français · винодельня, тёмный бордо" ;;
    14-es-yoga)       echo "Español  · йога-студия, спокойный зелёный" ;;
    15-en-books)      echo "English  · книжный магазин, литературный" ;;
    *)                echo "" ;;
  esac
}

list_templates(){ find "$TPL_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort; }

case "${1:-}" in
  -l|--list) echo "Available templates:"; list_templates; exit 0 ;;
  -h|--help)
    cat <<USAGE
Usage: bash deploy.sh [template-name]
  (no argument)   install a RANDOM template
  template-name   install a specific template (see --list)
  -l, --list      list available templates
Environment:
  WEBROOT=$WEBROOT
  KEEP_BACKUPS=$KEEP_BACKUPS
USAGE
    exit 0 ;;
esac

[ -d "$TPL_DIR" ] || { echo "ERROR: templates dir not found: $TPL_DIR" >&2; exit 1; }

if [ -n "${1:-}" ]; then
  CHOICE="$1"
else
  mapfile -t ALL < <(list_templates)
  [ "${#ALL[@]}" -gt 0 ] || { echo "ERROR: no templates found in $TPL_DIR" >&2; exit 1; }
  CHOICE="${ALL[$((RANDOM % ${#ALL[@]}))]}"
fi

SRC="$TPL_DIR/$CHOICE"
[ -f "$SRC/index.html" ] || { echo "ERROR: template '$CHOICE' has no index.html" >&2; exit 1; }

# 1) back up the current site
if [ -e "$WEBROOT" ]; then
  BK="/root/site.bak.$(date +%Y%m%d-%H%M%S)"
  cp -a "$WEBROOT" "$BK"
  echo "backup  -> $BK"
fi

# 2) install the chosen template
mkdir -p "$WEBROOT"
find "$WEBROOT" -mindepth 1 -delete
cp -a "$SRC/." "$WEBROOT/"
find "$WEBROOT" -type d -exec chmod 755 {} +
find "$WEBROOT" -type f -exec chmod 644 {} +

# 3) prune old backups, keep the newest KEEP_BACKUPS
ls -1dt /root/site.bak.* 2>/dev/null | tail -n +"$((KEEP_BACKUPS + 1))" | xargs -r rm -rf

# 4) pretty summary
DESC="$(describe "$CHOICE")"
FILES="$(find "$WEBROOT" -type f | wc -l | tr -d ' ')"
SIZE="$(du -sh "$WEBROOT" 2>/dev/null | cut -f1)"

echo
echo "${C_OK}╔══════════════════════════════════════════════════════╗${C_RST}"
echo "${C_OK}║              ✅  SELFSTEAL ГОТОВ                       ║${C_RST}"
echo "${C_OK}╚══════════════════════════════════════════════════════╝${C_RST}"
echo "  ${C_INFO}Шаблон :${C_RST} $CHOICE"
[ -n "$DESC" ] && echo "  ${C_INFO}Описание:${C_RST} $DESC"
echo "  ${C_INFO}Webroot:${C_RST} $WEBROOT  ${C_DIM}($FILES файл(ов), $SIZE)${C_RST}"
[ -n "${BK:-}" ] && echo "  ${C_INFO}Бэкап  :${C_RST} $BK"
echo "  ${C_DIM}Caddy отдаёт файлы с диска вживую — перезапуск не нужен.${C_RST}"
echo
