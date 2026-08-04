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
const PORT = 8791;
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

// App Store Connect asks for a specific pixel size per display class, and which
// slot it offers depends on the app record — so both are buildable:
//   node scripts/shots_ios.mjs 6.9   ->  1320x2868 (iPhone 16/17 Pro Max)
//   node scripts/shots_ios.mjs 6.5   ->  1284x2778 (iPhone 13/14 Pro Max)
const SIZES = { '6.9': [440, 956], '6.5': [428, 926], 'play': [360, 640] };
const SIZE = process.argv[2] ?? '6.9';
if (!SIZES[SIZE]) throw new Error(`unknown size ${SIZE}; use 6.9 or 6.5`);
const [VW, VH] = SIZES[SIZE];
const DSF = 3;
const OUT = join(ROOT, `store/screenshots/ios-${SIZE}`);

// Six NavigationDestinations spread evenly; icons sit just above the home indicator.
const TABS = ['home', 'events', 'map', 'levadas', 'news', 'roots'];
const tabX = (i) => Math.round((VW / TABS.length) * (i + 0.5));
// Derived, not hardcoded: the bar hugs the bottom, so a shorter viewport moves it
// up with the same offset. A fixed 886 happened to still land inside the bar at
// 6.5", but it would have silently tapped nothing on a smaller device.
const TAB_Y = VH - 40;

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
  // OSM's tile policy turns away automated clients, and headless Chrome
  // announces itself as one — the tiles under the Home map silently never
  // arrived, so the card shot as bare polylines on grey.
  '--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36',
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

// Count in-flight requests so a capture can wait for the network to go quiet.
// A fixed timer is not enough: the Home card is a real map, and its OSM tiles
// were still arriving when the shutter fired — the store screenshot came out
// with bare polylines on grey, which reads as a broken map rather than a slow one.
let inflight = 0;
ws.addEventListener('message', (e) => {
  const m = JSON.parse(e.data);
  if (m.method === 'Network.requestWillBeSent') inflight++;
  else if (m.method === 'Network.loadingFinished' ||
           m.method === 'Network.loadingFailed') inflight--;
});

const settle = async ({ quietMs = 1500, timeoutMs = 30000 } = {}) => {
  const deadline = Date.now() + timeoutMs;
  let quietSince = null;
  while (Date.now() < deadline) {
    await sleep(250);
    if (inflight <= 0) {
      quietSince ??= Date.now();
      if (Date.now() - quietSince >= quietMs) return;
    } else {
      quietSince = null;
    }
  }
};

await cdp('Page.enable');
await cdp('Network.enable');
await cdp('Emulation.setDeviceMetricsOverride',
  { width: VW, height: VH, deviceScaleFactor: DSF, mobile: true });
await cdp('Page.reload');

// Flutter web boots the engine, then each tab fetches its own JSON from the site.
await sleep(6000);
await settle();

// Nudge the layout by one pixel and back. The Home teaser is a FlutterMap with
// interaction disabled, so if it measured zero height on the first frame it never
// asks for tiles again — nothing can trigger a re-request. The resize does.
await cdp('Emulation.setDeviceMetricsOverride',
  { width: VW, height: VH + 1, deviceScaleFactor: DSF, mobile: true });
await sleep(400);
await cdp('Emulation.setDeviceMetricsOverride',
  { width: VW, height: VH, deviceScaleFactor: DSF, mobile: true });
await settle();

const tap = async (x, y) => {
  for (const type of ['mousePressed', 'mouseReleased']) {
    await cdp('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 });
    await sleep(60);
  }
};

await mkdir(OUT, { recursive: true });

const shoot = async (i, name) => {
  const { data } = await cdp('Page.captureScreenshot', { format: 'png' });
  const file = join(OUT, `${i + 1}-${name}.png`);
  await writeFile(file, Buffer.from(data, 'base64'));
  console.log(`${file}`);
};

// Home is shot LAST, not first. Its teaser map has interaction disabled, so if it
// measured zero height on the first frame it never re-requests tiles — but coming
// back to the tab forces a fresh layout pass, and the tiles arrive.
for (const [i, name] of TABS.entries()) {
  if (i === 0) continue;
  await tap(tabX(i), TAB_Y);
  await sleep(2500);
  await settle();
  await shoot(i, name);
}
await tap(tabX(0), TAB_Y);
await sleep(3000);
await settle();
await shoot(0, TABS[0]);

ws.close();
chrome.kill();
server.close();
