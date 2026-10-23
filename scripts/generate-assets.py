#!/usr/bin/env python3
"""Generates assets/logo.svg and the animated assets/preview.svg used in the README."""
import math
from pathlib import Path

ASSETS = Path(__file__).resolve().parent.parent / "assets"
ORANGE = "#D97757"
YELLOW = "#FFD60A"
RED = "#FF453A"
FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', Helvetica, Arial, sans-serif"
RAY_LENGTHS = [1.0, 0.78, 0.93, 0.7, 0.97, 0.82, 0.74, 0.99, 0.8, 0.9, 0.72, 0.86]


def starburst(cx, cy, size):
    """Same geometry as Sources/ClaudeBar/ClaudeIcon.swift, with the y axis flipped."""
    base, tip_width = size * 0.04, size * 0.13
    max_radius = size / 2 - size / 32
    parts = []
    for index, length in enumerate(RAY_LENGTHS):
        angle = 0.2 + 2 * math.pi * index / len(RAY_LENGTHS)
        dx, dy = math.cos(angle), -math.sin(angle)
        nx, ny = -dy, dx
        reach = max_radius * length - tip_width / 2
        tx, ty = cx + dx * reach, cy + dy * reach
        points = [
            (cx + nx * base / 2, cy + ny * base / 2),
            (tx + nx * tip_width / 2, ty + ny * tip_width / 2),
            (tx - nx * tip_width / 2, ty - ny * tip_width / 2),
            (cx - nx * base / 2, cy - ny * base / 2),
        ]
        parts.append("M" + " L".join(f"{x:.2f},{y:.2f}" for x, y in points) + "Z")
        r = tip_width / 2
        parts.append(f"M{tx - r:.2f},{ty:.2f} a{r:.2f},{r:.2f} 0 1,0 {2 * r:.2f},0 a{r:.2f},{r:.2f} 0 1,0 {-2 * r:.2f},0Z")
    return " ".join(parts)


def logo():
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <title>ClaudeBar</title>
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#2B2622"/>
      <stop offset="1" stop-color="#16130F"/>
    </linearGradient>
  </defs>
  <rect width="128" height="128" rx="28" fill="url(#bg)"/>
  <rect x="0.5" y="0.5" width="127" height="127" rx="27.5" fill="none" stroke="#fff" stroke-opacity="0.08"/>
  <path d="{starburst(64, 64, 84)}" fill="{ORANGE}"/>
</svg>
'''


def level_color(percent):
    return RED if percent > 80 else YELLOW if percent > 50 else None


def fade(index, count):
    """keyTimes/values that show state `index` for its slice of the cycle, with a short cross-fade."""
    start, end, f = index / count, (index + 1) / count, 0.03
    if index == 0:
        return f"0;{end - f:.3f};{end:.3f};{1 - f:.3f};1", "1;1;0;0;1"
    return f"0;{start - f:.3f};{start:.3f};{end - f:.3f};{end:.3f};1", "0;0;1;1;0;0"


def preview():
    width, height, bar = 760, 250, 30
    item_x = 540
    menu_x, menu_y, menu_w, menu_h = item_x - 140, bar + 8, 340, 190
    states = [(7, 10, "em 3 horas"), (65, 34, "em 2 horas"), (92, 58, "em 41 minutos")]
    duration = "7.5s"

    def usage_row(y, title, percent, reset):
        color = level_color(percent)
        marker = f'<circle cx="{menu_x + 22}" cy="{y - 4.5}" r="5" fill="{color}"/>' if color else ""
        text_x = menu_x + (34 if color else 18)
        return (f'{marker}<text x="{text_x}" y="{y}">{title}: {percent}% '
                f'<tspan fill="#A1A1A6">- renova {reset}</tspan></text>')

    groups = []
    for index, (session, weekly, reset) in enumerate(states):
        key_times, values = fade(index, len(states))
        color = level_color(session) or "#FFFFFF"
        groups.append(f'''
    <g opacity="{1 if index == 0 else 0}">
      <animate attributeName="opacity" dur="{duration}" repeatCount="indefinite" keyTimes="{key_times}" values="{values}"/>
      <path d="{starburst(item_x + 8, bar / 2, 16)}" fill="{color}"/>
      <text x="{item_x + 20}" y="{bar / 2 + 4.5}" font-weight="600" fill="{color}">{session}%</text>
      {usage_row(menu_y + 30, "Sessão (5h)", session, reset)}
      {usage_row(menu_y + 56, "Semanal (7 dias)", weekly, "em 6 dias")}
    </g>''')

    def menu_item(y, label, shortcut=""):
        right = f'<text x="{menu_x + menu_w - 18}" y="{y}" text-anchor="end" fill="#A1A1A6">{shortcut}</text>' if shortcut else ""
        return f'<text x="{menu_x + 18}" y="{y}">{label}</text>{right}'

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" font-family="{FONT}" font-size="13">
  <title>ClaudeBar preview: session usage going from 7% to 65% (yellow) to 92% (red)</title>
  <defs>
    <linearGradient id="wallpaper" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#3A1F5C"/>
      <stop offset="0.55" stop-color="#B4533A"/>
      <stop offset="1" stop-color="#F0A35E"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.75" cy="0.1" r="0.8">
      <stop offset="0" stop-color="#fff" stop-opacity="0.18"/>
      <stop offset="1" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>
    <clipPath id="frame"><rect width="{width}" height="{height}" rx="16"/></clipPath>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="160%">
      <feDropShadow dx="0" dy="10" stdDeviation="14" flood-color="#000" flood-opacity="0.45"/>
    </filter>
  </defs>
  <g clip-path="url(#frame)" fill="#F2F2F2">
    <rect width="{width}" height="{height}" fill="url(#wallpaper)"/>
    <rect width="{width}" height="{height}" fill="url(#glow)"/>

    <rect width="{width}" height="{bar}" fill="#1C1C1E" fill-opacity="0.72"/>
    <circle cx="24" cy="{bar / 2}" r="6"/>
    <text x="44" y="{bar / 2 + 4.5}" font-weight="700">Finder</text>
    <text x="104" y="{bar / 2 + 4.5}">File</text>
    <text x="140" y="{bar / 2 + 4.5}">Edit</text>
    <text x="177" y="{bar / 2 + 4.5}">View</text>
    <text x="219" y="{bar / 2 + 4.5}">Window</text>
    <text x="612" y="{bar / 2 + 4.5}" fill-opacity="0.85">◐</text>
    <rect x="636" y="{bar / 2 - 5}" width="22" height="10" rx="3" fill="none" stroke="#F2F2F2" stroke-opacity="0.85"/>
    <rect x="638" y="{bar / 2 - 3}" width="15" height="6" rx="1.5" fill-opacity="0.85"/>
    <text x="672" y="{bar / 2 + 4.5}">Qui 14:32</text>
    <rect x="{item_x - 6}" y="4" width="62" height="{bar - 8}" rx="5" fill="#fff" fill-opacity="0.16"/>

    <rect x="{menu_x}" y="{menu_y}" width="{menu_w}" height="{menu_h}" rx="10" fill="#2C2C2E" fill-opacity="0.94" filter="url(#shadow)"/>
    <rect x="{menu_x + 0.5}" y="{menu_y + 0.5}" width="{menu_w - 1}" height="{menu_h - 1}" rx="9.5" fill="none" stroke="#fff" stroke-opacity="0.12"/>
    <text x="{menu_x + 18}" y="{menu_y + 82}" fill="#A1A1A6">Atualizado às 14:32</text>
    <line x1="{menu_x + 12}" y1="{menu_y + 98}" x2="{menu_x + menu_w - 12}" y2="{menu_y + 98}" stroke="#fff" stroke-opacity="0.12"/>
    {menu_item(menu_y + 122, "Atualizar agora", "⌘R")}
    <path d="M{menu_x + 18},{menu_y + 143} l3.5,3.5 l7,-8" fill="none" stroke="#F2F2F2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <text x="{menu_x + 36}" y="{menu_y + 148}">Abrir ao iniciar sessão</text>
    {menu_item(menu_y + 174, "Sair", "⌘Q")}
{"".join(groups)}
  </g>
</svg>
'''


if __name__ == "__main__":
    ASSETS.mkdir(exist_ok=True)
    (ASSETS / "logo.svg").write_text(logo())
    (ASSETS / "preview.svg").write_text(preview())
    print("Wrote assets/logo.svg and assets/preview.svg")
