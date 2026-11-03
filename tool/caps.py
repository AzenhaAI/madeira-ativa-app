# -*- coding: utf-8 -*-
"""Captioned store screenshots: a headline over a framed phone screen.

  python3 caps.py <shots_dir_prefix> <out_dir> <W> <H> [langs]
  e.g. caps.py ~/Projects/ativa/store/screenshots/v195-6.9 out 1320 2868 en,pt,de,ru
"""
import os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT_B = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_R = '/System/Library/Fonts/Supplemental/Arial.ttf'
GREEN = (22, 150, 112); TEAL = (12, 104, 128)

FRAMES = ['1-home', '5-events', '4b-busroute', '2-levadas', '3b-trail-profile', '8-orient', '9-stats', '6-ask', '7-news', '10-words']
CAP = {
 'en': [("The island at a glance", "Weather where it is, and what today is good for"),
        ("Races and festas", "With registration alerts for what you follow"),
        ("Buses by the clock", "Door to door, with changes and real times"),
        ("44 levadas, today", "Open, partly open or closed, from the official feed"),
        ("Know the climb", "Elevation, weather on the trail, nearby walks"),
        ("Orienteering, explained", "Every map symbol, control descriptions, a compass"),
        ("Trail races in numbers", "MIUT and every race: finishers, records, countries"),
        ("Ask about the island", "Answers from live data, facts underneath"),
        ("Island news, in your language", "Madeira's outlets, auto-translated where needed"),
        ("Madeiran words", "The island's speech in a 1950 dictionary, a word a day")],
 'pt': [("A ilha num relance", "O tempo onde ele está, e para que serve o dia"),
        ("Provas e festas", "Com alertas de inscrições do que segue"),
        ("Autocarros com horas", "Porta a porta, com transbordos e partidas reais"),
        ("44 levadas, hoje", "Abertas, parciais ou fechadas, do feed oficial"),
        ("Conheça a subida", "Perfil, tempo no percurso, veredas próximas"),
        ("Orientação explicada", "Todos os símbolos do mapa, a sinalética, a bússola"),
        ("O trail em números", "O MIUT e todas as provas: finalistas, recordes, países"),
        ("Pergunte sobre a ilha", "Respostas de dados em direto, factos por baixo"),
        ("Notícias da ilha na sua língua", "Imprensa da Madeira, traduzida quando preciso"),
        ("Palavras madeirenses", "A fala da ilha num dicionário de 1950, uma palavra por dia")],
 'de': [("Die Insel auf einen Blick", "Wetter dort, wo es ist, und wofür der Tag taugt"),
        ("Läufe und Feste", "Mit Anmelde-Hinweisen für das, was du verfolgst"),
        ("Busse nach Fahrplan", "Von Tür zu Tür, mit Umstiegen und echten Zeiten"),
        ("44 Levadas, heute", "Offen, teilweise oder gesperrt, aus dem offiziellen Feed"),
        ("Kenne den Anstieg", "Höhenprofil, Wetter am Weg, Wege in der Nähe"),
        ("Orientierungslauf erklärt", "Alle Kartenzeichen, Postenbeschreibung, Kompass"),
        ("Trailrennen in Zahlen", "MIUT und alle Rennen: Finisher, Rekorde, Länder"),
        ("Frag nach der Insel", "Antworten aus Live-Daten, Fakten darunter"),
        ("Inselnachrichten in deiner Sprache", "Madeiras Medien, bei Bedarf übersetzt"),
        ("Madeirische Wörter", "Die Sprache der Insel, ein Wörterbuch von 1950")],
 'ru': [("Остров с первого взгляда", "Погода там, где она есть, и чем хорош день"),
        ("Забеги и праздники", "С напоминаниями о регистрации"),
        ("Автобусы по расписанию", "От двери до двери, с пересадками и временем"),
        ("44 левады сегодня", "Открыта, частично или закрыта — по официальным данным"),
        ("Знай подъём заранее", "Профиль высот, погода на тропе, соседние тропы"),
        ("Ориентирование: понятно", "Все знаки карты, легенды КП, компас"),
        ("Трейлы в цифрах", "MIUT и все гонки: финишёры, рекорды, страны"),
        ("Спроси об острове", "Ответы по живым данным, факты под ними"),
        ("Новости острова на вашем языке", "Пресса Мадейры, с переводом где нужно"),
        ("Мадейрские слова", "Речь острова в словаре 1950 года, слово дня")],
}


def bg(W, H):
    im = Image.new('RGB', (W, H)); px = im.load()
    for y in range(H):
        for x in range(0, W, 1):
            t = x / W; u = y / H; k = min(1, t * 0.6 + u * 0.7)
            px[x, y] = tuple(min(255, int(GREEN[i] * (1 - k) + TEAL[i] * k + 20 * (1 - u))) for i in range(3))
    return im.convert('RGBA')


def phone(shot, w):
    bez = int(w * 0.035); r = int(w * 0.15)
    sw = w - 2 * bez; sh = int(shot.height * sw / shot.width)
    s = shot.resize((sw, sh), Image.LANCZOS)
    body = Image.new('RGBA', (w, sh + 2 * bez), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle((0, 0, w - 1, sh + 2 * bez - 1), radius=r, fill=(20, 20, 20, 255))
    m = Image.new('L', (sw, sh), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=r - bez, fill=255)
    body.paste(s, (bez, bez), m)
    return body


def wrap(d, text, font, maxw):
    lines = ['']
    for w in text.split(' '):
        t = (lines[-1] + ' ' + w).strip()
        if d.textlength(t, font=font) > maxw and lines[-1]:
            lines.append(w)
        else:
            lines[-1] = t
    return lines


def make(shot_path, title, sub, W, H, out):
    base = bg(W, H); d = ImageDraw.Draw(base)
    ft = ImageFont.truetype(FONT_B, int(W * 0.078)); fs = ImageFont.truetype(FONT_R, int(W * 0.040))
    y = int(H * 0.055)
    for ln in wrap(d, title, ft, W * 0.88)[:2]:
        d.text((W // 2, y), ln, font=ft, fill=(255, 255, 255), anchor='ma'); y += int(ft.size * 1.12)
    y += int(H * 0.008)
    for ln in wrap(d, sub, fs, W * 0.86)[:2]:
        d.text((W // 2, y), ln, font=fs, fill=(226, 244, 236), anchor='ma'); y += int(fs.size * 1.3)
    shot = Image.open(shot_path).convert('RGB')
    # A tablet frame is 3:4; at the phone's width it would run off the bottom.
    pw = int(W * (0.80 if H / W > 1.8 else 0.68)); ph = phone(shot, pw)
    top = y + int(H * 0.03)
    blur = 30; a = ph.split()[3].point(lambda v: int(v * 110 / 255))
    sh = Image.new('RGBA', (pw + 4 * blur, ph.height + 4 * blur), (0, 0, 0, 0)); sh.paste((0, 0, 0, 255), (2 * blur, 2 * blur), a)
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    x = (W - pw) // 2
    base.alpha_composite(sh, (x - 2 * blur, top - 2 * blur + 20)); base.alpha_composite(ph, (x, top))
    base.convert('RGB').save(out, optimize=True)


# The "Without a car: buses to the trails" custom product page: the planner,
# the network map, then the trails and the island it gets you to.
MAP_CAP = {'en': ("Bus stops on the map", "Tap a stop for its lines and next buses"),
           'pt': ("Paragens no mapa", "Toque numa paragem: linhas e próximos autocarros"),
           'de': ("Haltestellen auf der Karte", "Tipp auf eine Haltestelle: Linien und nächste Busse"),
           'ru': ("Остановки на карте", "Нажмите на остановку: линии и ближайшие автобусы")}


def cpp_bus():
    global FRAMES, CAP
    cap = {L: [v[FRAMES.index('4b-busroute')], MAP_CAP[L], v[FRAMES.index('2-levadas')], v[FRAMES.index('1-home')]]
           for L, v in CAP.items()}
    FRAMES, CAP = ['4b-busroute', '4-map', '2-levadas', '1-home'], cap


if __name__ == '__main__':
    if '--cpp-bus' in sys.argv:
        sys.argv.remove('--cpp-bus'); cpp_bus()
    pre, outdir, W, H = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    langs = (sys.argv[5] if len(sys.argv) > 5 else 'en,pt,de,ru').split(',')
    for L in langs:
        src = f'{pre}-{L}'
        if not os.path.isdir(src):
            print('skip', L, '(no shots)'); continue
        od = f'{outdir}/{L}'; os.makedirs(od, exist_ok=True)
        for i, (fr, (t, s)) in enumerate(zip(FRAMES, CAP[L]), 1):
            p = f'{src}/{fr}.png'
            if not os.path.exists(p): print('missing', p); continue
            make(p, t, s, W, H, f'{od}/{i}-{fr}.png')
        print(L, 'done')
