// App Store screenshots for the 6.9" iPhone slot (1320x2868), taken from the web
// build in headless Chrome.
//
// Why not the iOS simulator: driving it needs OS-level taps, and the app asks for
// notification permission on first launch — that native alert sits above the app
// and lands in every frame. Chrome has no such dialog, and emulating a 440x956
// viewport at deviceScaleFactor 3 lands exactly on Apple's required pixel size.
//
// Usage:  flutter build web --release && node scripts/shots_ios.mjs
// Output: store/screenshots/ios-6.9/<n>-<tab>.png

import { createServer } from 'node:http';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { extname, join } from 'node:path';

const ROOT = new URL('..', import.meta.url).pathname;
const WEB = join(ROOT, 'build/web');
const OUT = join(ROOT, 'store/screenshots/ios-6.9');
const PORT = 8791;
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

// 440x956 at dsf 3 = 1320x2868 — the 6.9" slot (iPhone 16/17 Pro Max).
const VW = 440, VH = 956, DSF = 3;

// Six NavigationDestinations spread evenly; icons sit just above the home indicator.
const TABS = ['home', 'events', 'map', 'levadas', 'news', 'roots'];
const tabX = (i) => Math.round((VW / TABS.length) * (i + 0.5));
const TAB_Y = 886;

const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json',
  '.css': 'text/css', '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.otf': 'font/otf', '.wasm': 'application/wasm' };

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const server = createServer(async (req, res) => {
  const path = decodeURIComponent(req.url.split('?')[0]);
  const file = join(WEB, path === '/' ? 'index.html' : path);
  try {
    const body = await readFile(file);
    res.writeHead(200, { 'content-type': MIME[extname(file)] ?? 'application/octet-stream' });
    res.end(body);
  } catch {
    res.writeHead(404).end('not found');
  }
});
await new Promise((r) => server.listen(PORT, r));

const chrome = spawn(CHROME, [
  '--headless=new', '--remote-debugging-port=9333', '--hide-scrollbars',
  '--no-first-run', '--no-default-browser-check',
  `--user-data-dir=/tmp/ativa-shots-profile`,
  `http://localhost:${PORT}/`,
], { stdio: 'ignore' });

// The debugging endpoint comes up a beat after the process does.
let wsUrl;
for (let i = 0; i < 40 && !wsUrl; i++) {
  await sleep(500);
  try {
    const list = await (await fetch('http://localhost:9333/json/list')).json();
    wsUrl = list.find((t) => t.type === 'page')?.webSocketDebuggerUrl;
  } catch { /* not listening yet */ }
}
if (!wsUrl) { chrome.kill(); server.close(); throw new Error('Chrome debugger never came up'); }

const ws = new WebSocket(wsUrl);
await new Promise((r) => ws.addEventListener('open', r, { once: true }));

let msgId = 0;
const pending = new Map();
ws.addEventListener('message', (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result ?? {}); pending.delete(m.id); }
});
const cdp = (method, params = {}) => new Promise((resolve) => {
  const id = ++msgId;
  pending.set(id, resolve);
  ws.send(JSON.stringify({ id, method, params }));
});

await cdp('Page.enable');
await cdp('Emulation.setDeviceMetricsOverride',
  { width: VW, height: VH, deviceScaleFactor: DSF, mobile: true });
await cdp('Page.reload');

// Flutter web boots the engine, then each tab fetches its own JSON from the site.
// Nothing here is worth a spinner in a store screenshot, so wait generously.
await sleep(12000);

const tap = async (x, y) => {
  for (const type of ['mousePressed', 'mouseReleased']) {
    await cdp('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 });
    await sleep(60);
  }
};

await mkdir(OUT, { recursive: true });
for (const [i, name] of TABS.entries()) {
  if (i > 0) { await tap(tabX(i), TAB_Y); await sleep(4500); }
  const { data } = await cdp('Page.captureScreenshot', { format: 'png' });
  const file = join(OUT, `${i + 1}-${name}.png`);
  await writeFile(file, Buffer.from(data, 'base64'));
  console.log(`${file}`);
}

ws.close();
chrome.kill();
server.close();
