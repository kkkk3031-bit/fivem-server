#!/usr/bin/env bash
# One-shot restore of the FiveM server on a fresh Linux box.
# Usage: bash setup.sh   (then: fivem key <cfxk_...> && fivem start)
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"

echo "== 1/4 latest FXServer build =="
URL=$(curl -s https://changelogs-live.fivem.net/api/changelog/versions/linux/server | grep -oP '"latest_download":"\K[^"]+')
mkdir -p "$BASE/server"
curl -L "$URL" -o "$BASE/server/fx.tar.xz"
tar -xf "$BASE/server/fx.tar.xz" -C "$BASE/server"
rm "$BASE/server/fx.tar.xz"

echo "== 1b/4 base resources (cfx-server-data) =="
if [ ! -d "$BASE/server-data/resources" ]; then
  git clone --depth 1 https://github.com/citizenfx/cfx-server-data.git /tmp/cfx-sd
  mkdir -p "$BASE/server-data"
  cp -r /tmp/cfx-sd/resources "$BASE/server-data/resources"
  rm -rf /tmp/cfx-sd
fi

echo "== 2/4 fivem CLI =="
mkdir -p "$HOME/.local/bin"
cp "$BASE/bin/fivem" "$HOME/.local/bin/fivem"
chmod +x "$HOME/.local/bin/fivem"

echo "== 3/4 crons (reboot autostart + 5-min watchdog) =="
(crontab -l 2>/dev/null | grep -vE 'fivem start|fivem-watchdog'
 echo '@reboot sleep 20 && [ -s "$HOME/fivem/license.key" ] && $HOME/.local/bin/fivem start'
 echo '*/5 * * * * echo "tick $(date)" >> $HOME/fivem/watchdog.log; [ -s "$HOME/fivem/license.key" ] && $HOME/.local/bin/fivem start >> $HOME/fivem/watchdog.log 2>&1 # fivem-watchdog'
) | crontab -

echo "== 4/4 done =="
echo "Now: fivem key <cfxk_... from https://portal.cfx.re/servers/registration-keys>"
echo "Then: fivem start"
