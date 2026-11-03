# -*- coding: utf-8 -*-
"""Fanned "three phones" store art for Madeira Ativa: three screenshots fanned
like a hand of cards (left, centre, right) over a green-to-teal field with a
day photo of the island faded in, the app icon and a title on the left.

Usage (from anywhere; paths are relative to the app repo this file lives in):

  python3 tool/fan.py [--set v195b-6.9] [--version 1.9.5-64] [--langs en,pt,de,ru]
                      [--text orient|ask|bus] [--holes DIR] [--holes-only]

Inputs:
  store/screenshots/<set>-<lang>/5-events.png, 1-home.png, 4b-busroute.png
      (iPhone 6.9" shots, 1320x2868: Events left, Home centre, bus route right)
  assets/hero/day_tallship.jpg   background photo
  assets/icon.png                logo tile
Outputs:
  store/PLAY-<version>/promo/feature-graphic-1024x500-<lang>.png   (Google Play)
  store/APPSTORE-<version>/header-3840x1646-<lang>.png             (App Store header)
  store/APPSTORE-<version>/search-3840x2560-<lang>.png             (App Store search)
  with --holes DIR, per lang and k in header|search: DIR/bg-<k>-<lang>.png (fan
  with the centre phone left out, larger), DIR/bgb-<k>-<lang>.png (same with the
  centre bezel drawn), DIR/mask-<k>-<lang>.png and DIR/scr-<k>-<lang>.json (where
  the clip goes) for mkvid2.sh / mkvid3.sh.

Defaults reproduce the 1.9.5 (64) art byte-for-byte in pixels
(store/APPSTORE-1.9.5-64, store/PLAY-1.9.5-64/promo). The 1.9.5 (57) art is
  --set v195-6.9 --version 1.9.5 --text ask
Recovered on 2026-11-02 from the session that wrote scratchpad/fan/fan.py and
fan2.py (19-22.10.2026).
"""
import os, sys, json, argparse
from PIL import Image, ImageDraw, ImageFont, ImageFilter

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.join(APP, 'store')
SHOTS = f'{ROOT}/screenshots'
SET = 'v195b-6.9'
FRAMES = ['5-events', '1-home', '4b-busroute']  # left, centre, right
PHOTO = os.path.join(APP, 'assets/hero/day_tallship.jpg')
ICON = os.path.join(APP, 'assets/icon.png')
FONT_B = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_R = '/System/Library/Fonts/Supplemental/Arial.ttf'
# 1.9.5 (57): subtitle ends with Ask AI
TXT_ASK = {
  'en': ('Madeira, outdoors,', 'today', 'The island at a glance · levadas · island buses · races and festas · Ask AI'),
  'pt': ('A Madeira ao ar livre,', 'hoje', 'A ilha num relance · levadas · autocarros · provas e festas · Pergunte à IA'),
  'de': ('Madeira draußen,', 'heute', 'Die Insel auf einen Blick · Levadas · Busse der Insel · Läufe und Feste · Ask AI'),
  'ru': ('Мадейра,', 'на воздухе, сегодня', 'Остров с первого взгляда · левады · автобусы · забеги и праздники · Ask AI'),
}
# 1.9.5 (64) and later: subtitle ends with orienteering
TXT_ORIENT = {
  'en': ('Madeira, outdoors,', 'today', 'The island at a glance · levadas · island buses · races and festas · orienteering'),
  'pt': ('A Madeira ao ar livre,', 'hoje', 'A ilha num relance · levadas · autocarros · provas e festas · orientação'),
  'de': ('Madeira draußen,', 'heute', 'Die Insel auf einen Blick · Levadas · Busse der Insel · Läufe und Feste · Orientierungslauf'),
  'ru': ('Мадейра,', 'на воздухе, сегодня', 'Остров с первого взгляда · левады · автобусы · забеги и праздники · ориентирование'),
}
# 1.9.6: the buses run by the clock now
TXT_BUS = {
  'en': ('Madeira, outdoors,', 'today', 'The island at a glance · levadas · buses by the clock · races and festas · orienteering'),
  'pt': ('A Madeira ao ar livre,', 'hoje', 'A ilha num relance · levadas · autocarros com horas · provas e festas · orientação'),
  'de': ('Madeira draußen,', 'heute', 'Die Insel auf einen Blick · Levadas · Busse nach Fahrplan · Läufe und Feste · Orientierungslauf'),
  'ru': ('Мадейра,', 'на воздухе, сегодня', 'Остров с первого взгляда · левады · автобусы по расписанию · забеги и праздники · ориентирование'),
}
TXT = TXT_ORIENT

GREEN = (22, 150, 112); TEAL = (12, 104, 128); CREAM = (250, 248, 242); ORANGE = (242, 166, 90)

def phone(img, w):
    """A screenshot inside a rounded dark bezel, scaled to width w (bezel included)."""
    bez = int(w * 0.035); r = int(w * 0.16)
    sw = w - 2 * bez; sh = int(img.height * sw / img.width)
    shot = img.resize((sw, sh), Image.LANCZOS)
    body = Image.new('RGBA', (w, sh + 2 * bez), (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    d.rounded_rectangle((0, 0, w - 1, sh + 2 * bez - 1), radius=r, fill=(20, 20, 20, 255))
    mask = Image.new('L', (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=r - bez, fill=255)
    body.paste(shot, (bez, bez), mask)
    return body

def profile_card(path):
    """The trail page from its header straight to the elevation profile and
    the weather: the scrolled-past glossary is cut out."""
    im = Image.open(path).convert('RGB'); W, H = im.size
    head = im.crop((0, 0, W, int(H * 0.094)))
    # The chart's pale fill marks the profile; its title sits ~330 px above
    # the first filled row at this scale. The text above it differs by
    # language, so the place is measured, not assumed.
    px = im.load()
    def fill(c): r, g, b = c; return 200 <= g <= 240 and r < g - 6 and b < g + 6 and r > 150
    top = int(H * 0.335)
    for y in range(int(H * 0.15), int(H * 0.75), 4):
        if sum(1 for x in range(100, W - 100, 10) if fill(px[x, y])) > (W - 200) / 10 * 0.5:
            top = y - 330; break
    body = im.crop((0, top, W, H))
    out = Image.new('RGB', (W, H), (250, 248, 242))
    out.paste(head, (0, 0)); out.paste(body, (0, head.height))
    return out

def shadow(card, blur=28, alpha=120):
    a = card.split()[3].point(lambda v: int(v * alpha / 255))
    sh = Image.new('RGBA', (card.width + 4 * blur, card.height + 4 * blur), (0, 0, 0, 0))
    sh.paste((0, 0, 0, 255), (2 * blur, 2 * blur), a)
    return sh.filter(ImageFilter.GaussianBlur(blur))

def field(W, H, photo):
    """Green-teal gradient with the photo blended in on the right."""
    base = Image.new('RGB', (W, H))
    px = base.load()
    for x in range(W):
        t = x / W
        for y in range(H):
            u = y / H
            k = min(1, t * 0.9 + u * 0.35)
            px[x, y] = tuple(min(255, int(GREEN[i] * (1 - k) + TEAL[i] * k + 22 * (1 - u) * (1 - t))) for i in range(3))
    ph = Image.open(photo).convert('RGB')
    pw = int(W * 0.62); phh = int(ph.height * pw / ph.width)
    if phh < H: pw = int(ph.width * H / ph.height); phh = H
    ph = ph.resize((pw, phh), Image.LANCZOS).crop((0, (phh - H) // 2, pw, (phh - H) // 2 + H))
    mask = Image.new('L', (pw, H), 0)
    md = ImageDraw.Draw(mask)
    for x in range(pw):
        md.line([(x, 0), (x, H)], fill=int(255 * min(1, max(0, (x / pw - 0.35) / 0.5)) * 0.16))
    base.paste(ph, (W - pw, 0), mask)
    return base.convert('RGBA')

def compose(W, H, lang, out, title_scale=1.0, center=None):
    bg = field(W, H, PHOTO)
    L = f'{SHOTS}/{SET}-{lang}'
    frames = [Image.open(f'{L}/{n}.png') for n in FRAMES]
    # the hand of cards: centre upright, left and right fanned out and down
    pw = int(min(H * 0.40, W * (0.16 if W / H > 2 else 0.175)))
    big = 1.16
    if center == 'hole':
        # as large as the frame allows: the centre phone's height (screen
        # 2868/1320 of its width plus the bezel) fills 94% of the frame
        big = (H * 0.94) / (pw * (2868 / 1320 * 0.93 + 0.07))
    side = 0.78 if center == 'hole' else 1.0
    cards = [phone(f, int(pw * (big if i == 1 else side))) for i, f in enumerate(frames)]
    cx = int(W * (0.775 if W / H > 2 else 0.765)); cy = int(H * (0.60 if W / H > 2 else 0.57))
    if center == 'hole':
        cy = H // 2
        cx = int(W * 0.80)
    # a hand of cards: the outer two lean away from the centre and drop a little
    spread = 1.12 if center == 'hole' else 0.98
    specs = [(17, -int(pw * spread), int(pw * 0.20)), (0, 0, 0 if center == 'hole' else -int(pw * 0.10)), (-17, int(pw * spread), int(pw * 0.20))]
    order = [0, 2] if center == 'hole' else [0, 2, 1]
    geo = {}
    for i in order:
        ang, dx, dy = specs[i]
        c = cards[i].rotate(ang, expand=True, resample=Image.BICUBIC)
        sh = shadow(c)
        x = cx + dx - c.width // 2; y = cy + dy - c.height // 2
        bg.alpha_composite(sh, (x - 2 * 28, y - 2 * 28 + 18))
        bg.alpha_composite(c, (x, y))
    ang, dx, dy = specs[1]; c = cards[1]
    geo['center'] = (cx + dx - c.width // 2, cy + dy - c.height // 2, c.width, c.height, c.width)
    d = ImageDraw.Draw(bg)
    # logo tile
    logo = Image.open(ICON).convert('RGBA')
    ls = int(H * 0.17); logo = logo.resize((ls, ls), Image.LANCZOS)
    lm = Image.new('L', (ls, ls), 0); ImageDraw.Draw(lm).rounded_rectangle((0, 0, ls - 1, ls - 1), radius=int(ls * 0.22), fill=255)
    bg.paste(logo, (int(W * 0.055), int(H * 0.17)), lm)
    t1, t2, sub = TXT[lang]
    fs = int(H * 0.092 * title_scale); f1 = ImageFont.truetype(FONT_B, fs); f2 = ImageFont.truetype(FONT_R, int(H * 0.047 * title_scale))
    # The title must stay clear of the fan: shrink it until the widest line
    # fits the left 47% of the frame.
    probe = ImageDraw.Draw(Image.new('RGB', (10, 10)))
    while fs > 10 and max(probe.textlength(t, font=f1) for t in TXT[lang][:2]) > W * 0.47:
        fs -= 2; f1 = ImageFont.truetype(FONT_B, fs)
    x0 = int(W * 0.055); y0 = int(H * 0.42)
    d.text((x0, y0), t1, font=f1, fill=(255, 255, 255))
    d.text((x0, y0 + int(fs * 1.08)), t2, font=f1, fill=(255, 255, 255))
    words = sub.split(' '); lines = ['']; maxw = int(W * (0.46 if W / H > 2 else 0.40))
    for wd in words:
        trial = (lines[-1] + ' ' + wd).strip()
        if d.textlength(trial, font=f2) > maxw and lines[-1]: lines.append(wd)
        else: lines[-1] = trial
    for i, ln in enumerate(lines[:3]):
        d.text((x0, y0 + int(fs * 2.35) + i * int(f2.size * 1.3)), ln, font=f2, fill=(232, 246, 238))
    bg.convert('RGB').save(out, quality=95)
    print(out)
    return geo

def holes(V, lang):
    """Video backgrounds: the fan with the centre phone left out (and bigger),
    its bezel drawn, plus the screen mask and position for the clip."""
    for k, (W, H, ts) in {'header': (3840, 1646, 0.95), 'search': (3840, 2560, 0.68)}.items():
        g = compose(W, H, lang, f'{V}/bg-{k}-{lang}.png', ts, center='hole')['center']
        x, y, w, h = g[0], g[1], g[2], g[3]
        bez = int(w * 0.035); r = int(w * 0.16)
        bg = Image.open(f'{V}/bg-{k}-{lang}.png').convert('RGB')
        ImageDraw.Draw(bg).rounded_rectangle((x, y, x + w - 1, y + h - 1), radius=r, fill=(20, 20, 20))
        bg.save(f'{V}/bgb-{k}-{lang}.png')
        sw, sh = w - 2 * bez, h - 2 * bez
        sw -= sw % 2; sh -= sh % 2
        m = Image.new('L', (sw, sh), 0)
        ImageDraw.Draw(m).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=r - bez, fill=255)
        m.save(f'{V}/mask-{k}-{lang}.png')
        json.dump({'sx': x + bez, 'sy': y + bez, 'sw': sw, 'sh': sh}, open(f'{V}/scr-{k}-{lang}.json', 'w'))

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description='Fanned three-phone store art.')
    ap.add_argument('--set', default=SET, help='screenshot set prefix under store/screenshots (default %(default)s)')
    ap.add_argument('--version', default='1.9.5-64', help='output folders store/APPSTORE-<v>, store/PLAY-<v>/promo')
    ap.add_argument('--langs', default='en,pt,de,ru')
    ap.add_argument('--text', choices=['orient', 'ask', 'bus'], default='orient', help='subtitle variant')
    ap.add_argument('--holes', metavar='DIR', help='also write video backgrounds into DIR')
    ap.add_argument('--holes-only', action='store_true', help='only the video backgrounds (needs --holes)')
    a = ap.parse_args()
    SET = a.set
    TXT = {'orient': TXT_ORIENT, 'ask': TXT_ASK, 'bus': TXT_BUS}[a.text]
    A, P = f'{ROOT}/APPSTORE-{a.version}', f'{ROOT}/PLAY-{a.version}/promo'
    if a.holes_only and not a.holes: ap.error('--holes-only needs --holes DIR')
    if not a.holes_only: os.makedirs(A, exist_ok=True); os.makedirs(P, exist_ok=True)
    if a.holes: os.makedirs(a.holes, exist_ok=True)
    for L in a.langs.split(','):
        if not a.holes_only:
            compose(1024, 500, L, f'{P}/feature-graphic-1024x500-{L}.png')
            compose(3840, 1646, L, f'{A}/header-3840x1646-{L}.png', 0.95)
            compose(3840, 2560, L, f'{A}/search-3840x2560-{L}.png', 0.68)
        if a.holes: holes(a.holes, L)
