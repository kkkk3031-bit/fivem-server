// fivem-connect — tiny status + one-click connect page for khaled's FiveM server
const http = require('http');
const fs = require('fs');
const path = require('path');

const FIVEM = 'http://72.60.89.132:30120';
const PORT = process.env.PORT || 3000;
const INDEX = fs.readFileSync(path.join(__dirname, 'index.html'));

async function status() {
  try {
    const ctl = new AbortController();
    const t = setTimeout(() => ctl.abort(), 5000);
    const r = await fetch(`${FIVEM}/dynamic.json`, { signal: ctl.signal });
    clearTimeout(t);
    if (!r.ok) throw new Error('bad status');
    const d = await r.json();
    return {
      online: true,
      players: Number(d.clients) || 0,
      maxPlayers: Number(d.sv_maxclients) || 16,
      hostname: d.hostname || "khaled's FiveM server",
      gametype: d.gametype || '',
      map: d.mapname || '',
    };
  } catch {
    return { online: false, players: 0, maxPlayers: 16 };
  }
}

// UDP probe: sends the game protocol's getinfo packet to the server's UDP
// port from Railway's network — proves players outside can reach it.
function udpCheck() {
  return new Promise((resolve) => {
    const dgram = require('dgram');
    const sock = dgram.createSocket('udp4');
    const timer = setTimeout(() => { sock.close(); resolve({ udp: false, reason: 'timeout' }); }, 5000);
    sock.once('message', (msg) => {
      clearTimeout(timer); sock.close();
      resolve({ udp: msg.toString().includes('infoResponse'), from: 'railway' });
    });
    sock.once('error', () => { clearTimeout(timer); resolve({ udp: false, reason: 'socket error' }); });
    sock.send(Buffer.from('\xff\xff\xff\xffgetinfo joincheck', 'binary'), 30120, '72.60.89.132');
  });
}

http.createServer(async (req, res) => {
  if (req.url === '/api/udpcheck') {
    const r = await udpCheck();
    res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
    res.end(JSON.stringify(r));
    return;
  }
  if (req.url === '/api/players') {
    let list = [];
    try {
      const ctl = new AbortController();
      const t = setTimeout(() => ctl.abort(), 5000);
      const r = await fetch(`${FIVEM}/players.json`, { signal: ctl.signal });
      clearTimeout(t);
      if (r.ok) list = (await r.json()).map(p => ({ name: p.name, ping: p.ping }));
    } catch {}
    res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store', 'Access-Control-Allow-Origin': '*' });
    res.end(JSON.stringify(list));
    return;
  }
  if (req.url === '/api/status') {
    const s = await status();
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
      'Access-Control-Allow-Origin': '*',
    });
    res.end(JSON.stringify(s));
    return;
  }
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(INDEX);
}).listen(PORT, () => console.log(`fivem-connect listening on :${PORT}`));
