# -*- coding: utf-8 -*-
"""Link preview (og:image) for azenha.ai/ativa: the name, one line on what
the app does, and two framed screens. 1200x630.

  python3 og.py <shots_dir> <out.png> <lang>
"""
import os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from caps import bg, phone, wrap, FONT_B, FONT_R

LINE = {
    'en': "Trails, buses by the clock, races and festas: Madeira today",
    'pt': "Veredas, autocarros com horas, provas e festas: a Madeira hoje",
    'de': "Wege, Busse nach Fahrplan, Läufe und Feste: Madeira heute",
    'ru': "Тропы, автобусы по расписанию, забеги и праздники: Мадейра сегодня",
}


def make(shots, out, lang, W=1200, H=630):
    base = bg(W, H); d = ImageDraw.Draw(base)
    ft = ImageFont.truetype(FONT_B, 78); fs = ImageFont.truetype(FONT_R, 34); fu = ImageFont.truetype(FONT_B, 30)
    x0 = 64; y = 150
    d.text((x0, y), "Madeira Ativa", font=ft, fill=(255, 255, 255)); y += 104
    for ln in wrap(d, LINE[lang], fs, 560)[:3]:
        d.text((x0, y), ln, font=fs, fill=(226, 244, 236)); y += 46
    d.text((x0, H - 96), "azenha.ai/ativa", font=fu, fill=(190, 236, 214))
    # Two screens, the bus planner in front; each phone's shadow is drawn on a
    # padded layer so the blur is not cut off square at the edges.
    for name, dx, dy, rot in (('1-home', 655, 92, 7), ('4b-busroute', 880, 52, -4)):
        ph = phone(Image.open(f'{shots}/{name}.png').convert('RGB'), 236).rotate(rot, expand=True, resample=Image.BICUBIC)
        pad = 40
        sh = Image.new('RGBA', (ph.width + 2 * pad, ph.height + 2 * pad), (0, 0, 0, 0))
        sh.paste((0, 0, 0, 110), (pad, pad), ph.split()[3])
        base.alpha_composite(sh.filter(ImageFilter.GaussianBlur(16)), (dx - pad + 6, dy - pad + 14))
        base.alpha_composite(ph, (dx, dy))
    base.convert('RGB').save(out, optimize=True)


if __name__ == '__main__':
    make(sys.argv[1], sys.argv[2], sys.argv[3])
    print(sys.argv[2])
