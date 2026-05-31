#!/usr/bin/env bash
# selfsteal template deployer
# Picks a RANDOM static template (or a named one) and installs it into the
# Caddy webroot used by the Reality "selfsteal" decoy site.
set -euo pipefail

WEBROOT="${WEBROOT:-/var/www/site}"     # change with: WEBROOT=/path bash deploy.sh
KEEP_BACKUPS="${KEEP_BACKUPS:-5}"        # how many /root/site.bak.* to keep

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TPL_DIR="$SCRIPT_DIR/templates"

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

echo "deployed: $CHOICE"
echo "webroot : $WEBROOT"
ls -la "$WEBROOT"

# 3) prune old backups, keep the newest KEEP_BACKUPS
ls -1dt /root/site.bak.* 2>/dev/null | tail -n +"$((KEEP_BACKUPS + 1))" | xargs -r rm -rf

echo "done. (Caddy file_server serves from disk live - no reload needed)"
