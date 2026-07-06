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

echo "== 1c/4 vMenu =="
if [ ! -d "$BASE/server-data/resources/[local]/vMenu" ]; then
  VURL=$(curl -s https://api.github.com/repos/TomGrobbe/vMenu/releases/latest | grep -oP '"browser_download_url":\s*"\K[^"]+\.zip')
  mkdir -p "$BASE/server-data/resources/[local]/vMenu"
  curl -sL "$VURL" -o /tmp/vmenu.zip
  unzip -q -o /tmp/vmenu.zip -d "$BASE/server-data/resources/[local]/vMenu"
  rm /tmp/vmenu.zip
fi

echo "== 1d/4 pma-voice + bob74_ipl =="
LOCAL="$BASE/server-data/resources/[local]"
if [ ! -d "$LOCAL/pma-voice" ]; then
  PTAG=$(curl -s https://api.github.com/repos/AvarianKnight/pma-voice/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
  curl -sL "https://github.com/AvarianKnight/pma-voice/archive/refs/tags/$PTAG.zip" -o /tmp/pma.zip
  unzip -q -o /tmp/pma.zip -d /tmp && mv /tmp/pma-voice-* "$LOCAL/pma-voice" && rm /tmp/pma.zip
fi
if [ ! -d "$LOCAL/bob74_ipl" ]; then
  ITAG=$(curl -s https://api.github.com/repos/Bob74/bob74_ipl/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
  curl -sL "https://github.com/Bob74/bob74_ipl/archive/refs/tags/$ITAG.zip" -o /tmp/ipl.zip
  unzip -q -o /tmp/ipl.zip -d /tmp && mv /tmp/bob74_ipl-* "$LOCAL/bob74_ipl" && rm /tmp/ipl.zip
fi

echo "== 1e/4 mods pack (dpemotes, dpclothing, LegacyFuel, PolyZone, interact-sound) =="
for spec in "andristum/dpemotes dpemotes" "andristum/dpclothing dpclothing" \
            "InZidiuZ/LegacyFuel LegacyFuel" "mkafrin/PolyZone PolyZone" \
            "plunkettscott/interact-sound interact-sound"; do
  repo=${spec% *}; name=${spec#* }
  if [ ! -d "$LOCAL/$name" ]; then
    curl -sL "https://github.com/$repo/archive/refs/heads/master.zip" -o /tmp/mod.zip
    unzip -q -o /tmp/mod.zip -d /tmp && mv /tmp/"$(basename "$repo")"-master "$LOCAL/$name" && rm /tmp/mod.zip
  fi
done
# dpemotes: no MySQL on this box — keep SQL keybinding off
sed -i 's/SqlKeybinding = true,/SqlKeybinding = false, -- no database on this server/' "$LOCAL/dpemotes/Config.lua" || true

echo "== 1f/4 nightly backup + log-rotate crons =="
(crontab -l 2>/dev/null | grep -vE 'fivem-backup|fivem-logrotate'
 echo '0 5 * * * $HOME/.local/bin/fivem backup >> $HOME/fivem/backup.log 2>&1 # fivem-backup'
 echo '5 5 * * * [ $(stat -c%s $HOME/fivem/fxserver.log 2>/dev/null || echo 0) -gt 52428800 ] && cp $HOME/fivem/fxserver.log $HOME/fivem/fxserver.log.1 && truncate -s 0 $HOME/fivem/fxserver.log # fivem-logrotate'
) | crontab -

echo "== 2/4 fivem CLI =="
mkdir -p "$HOME/.local/bin"
cp "$BASE/bin/fivem" "$HOME/.local/bin/fivem"
chmod +x "$HOME/.local/bin/fivem"

echo "== 3/4 crons (reboot autostart + 5-min watchdog) =="
(crontab -l 2>/dev/null | grep -vE 'fivem start|fivem-watchdog'
 echo '@reboot sleep 20 && [ -s "$HOME/fivem/license.key" ] && $HOME/.local/bin/fivem startall'
 echo '*/5 * * * * echo "tick $(date)" >> $HOME/fivem/watchdog.log; [ -s "$HOME/fivem/license.key" ] && $HOME/.local/bin/fivem startall >> $HOME/fivem/watchdog.log 2>&1 # fivem-watchdog'
) | crontab -

echo "== 4/4 done =="
echo "Now: fivem key <cfxk_... from https://portal.cfx.re/servers/registration-keys>"
echo "Then: fivem start"
