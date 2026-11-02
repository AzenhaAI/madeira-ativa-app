"""Island bus network art: every line drawn on Madeira's outline, no text.
   busmap.py <network.json> <island.json> <out.png> <W> <H> [dark]"""
import json, re, sys
from PIL import Image, ImageDraw, ImageFilter

net, isl, out, W, H = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5])
dark = len(sys.argv) > 6
N = json.load(open(net)); I = json.load(open(isl))
ll = {'funchal': (32.6497, -16.9087), 'machico': (32.7175, -16.7616), 'portomoniz': (32.8667, -17.1667),
      'santana': (32.8048, -16.8820), 'calheta': (32.7203, -17.1756), 'saovicente': (32.7978, -17.0430),
      'ribeirabrava': (32.6732, -17.0631), 'pontadosol': (32.6810, -17.1031), 'camaradelobos': (32.6488, -16.9768)}
# least squares x = a*lon + b, y = c*lat + d
def fit(pairs):
    n = len(pairs); sx = sum(p for p, _ in pairs); sy = sum(q for _, q in pairs)
    sxx = sum(p * p for p, _ in pairs); sxy = sum(p * q for p, q in pairs)
    a = (n * sxy - sx * sy) / (n * sxx - sx * sx); return a, (sy - a * sx) / n
a, b = fit([(ll[k][1], I['pts'][k][0]) for k in ll]); c, d = fit([(ll[k][0], I['pts'][k][1]) for k in ll])
iw, ih = I['w'], I['h']
s = min(W * 0.86 / iw, H * 0.80 / ih); ox = (W - iw * s) / 2; oy = (H - ih * s) / 2 + H * 0.02
P = lambda lat, lon: (ox + (a * lon + b) * s, oy + (c * lat + d) * s)

def poly(path):
    nums = [float(x) for x in re.findall(r'-?\d+\.?\d*', path)]
    return [(ox + nums[i] * s, oy + nums[i + 1] * s) for i in range(0, len(nums) - 1, 2)]

def decode(e):
    pts, i, lat, lng = [], 0, 0, 0
    while i < len(e):
        for k in (0, 1):
            sh = r = 0
            while True:
                bb = ord(e[i]) - 63; i += 1; r |= (bb & 0x1f) << sh; sh += 5
                if bb < 0x20: break
            v = ~(r >> 1) if r & 1 else r >> 1
            if k == 0: lat += v
            else: lng += v
        pts.append((lat / 1e5, lng / 1e5))
    return pts

bg1, bg2 = ((16, 46, 38), (9, 28, 34)) if dark else ((214, 234, 238), (184, 214, 222))
im = Image.new('RGB', (W, H)); px = im.load()
for y in range(H):
    t = y / H; col = tuple(int(bg1[i] * (1 - t) + bg2[i] * t) for i in range(3))
    for x in range(W): px[x, y] = col
im = im.convert('RGBA')
land = Image.new('RGBA', (W, H), (0, 0, 0, 0)); dl = ImageDraw.Draw(land)
shape = poly(I['path'])
glow = Image.new('RGBA', (W, H), (0, 0, 0, 0)); ImageDraw.Draw(glow).polygon(shape, fill=(0, 0, 0, 90))
im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(int(W * 0.012))), (0, int(H * 0.008)))
dl.polygon(shape, fill=(28, 74, 56, 255) if dark else (238, 241, 228, 255), outline=(60, 120, 90, 255) if dark else (150, 180, 150, 255))
im.alpha_composite(land)
lines = Image.new('RGBA', (W, H), (0, 0, 0, 0)); dd = ImageDraw.Draw(lines)
lw = max(2, int(W * 0.0024))
for L in N['lines']:
    col = L.get('color') or '#2e9e5b'
    rgb = tuple(int(col[i:i + 2], 16) for i in (1, 3, 5)) + (235,)
    for p in L.get('paths', []):
        pts = [P(la, lo) for la, lo in decode(p)]
        if len(pts) > 1: dd.line(pts, fill=rgb, width=lw, joint='curve')
im.alpha_composite(lines.filter(ImageFilter.GaussianBlur(lw * 2.5)))
im.alpha_composite(lines)
st = ImageDraw.Draw(im); r = max(1.5, W * 0.0014)
inter = {i for i, L in enumerate(N['lines']) if L.get('src') != 'gtfs'}
for sd in N['stops']:
    if not any(li in inter for li in sd[4]) or sd[2] > 32.95: continue
    x, y = P(sd[2], sd[3]); st.ellipse((x - r, y - r, x + r, y + r), fill=(235, 245, 238, 255) if dark else (31, 77, 50, 255))
im.convert('RGB').save(out, optimize=True)
print(out, W, H)
