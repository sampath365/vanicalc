"""Generates the VaniCalc launcher icon, adaptive foreground and splash mark."""

from PIL import Image, ImageDraw, ImageFont

ORANGE = (255, 122, 24)
ORANGE_LIGHT = (255, 165, 60)
WHITE = (255, 255, 255)
SOFT = (233, 237, 245)
MUTED = (255, 235, 219)

FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(size, top, bottom):
    image = Image.new("RGB", (size, size), top)
    draw = ImageDraw.Draw(image)
    for y in range(size):
        draw.line([(0, y), (size, y)], fill=lerp(top, bottom, y / (size - 1)))
    return image


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_mark(image, cx, cy, scale):
    """Draws the calculator + microphone mark, nominal size 600 * scale."""
    draw = ImageDraw.Draw(image, "RGBA")
    s = scale
    w, h = 380 * s, 470 * s
    x0, y0 = cx - w / 2, cy - h / 2 - 15 * s

    rounded(draw, (x0 + 12 * s, y0 + 20 * s, x0 + w + 12 * s, y0 + h + 20 * s), 72 * s, (0, 0, 0, 38))
    rounded(draw, (x0, y0, x0 + w, y0 + h), 72 * s, WHITE)
    rounded(draw, (x0 + 45 * s, y0 + 50 * s, x0 + w - 45 * s, y0 + 165 * s), 30 * s, MUTED)
    rounded(draw, (x0 + 70 * s, y0 + 92 * s, x0 + w - 70 * s, y0 + 106 * s), 7 * s, ORANGE)
    rounded(draw, (x0 + 70 * s, y0 + 120 * s, x0 + w - 70 * s, y0 + 134 * s), 7 * s, ORANGE)

    pad = 38 * s
    button_w = (w - 4 * pad) / 3
    button_h = 62 * s
    colors = [ORANGE, SOFT, ORANGE, SOFT, ORANGE, SOFT, ORANGE, SOFT, ORANGE]
    for row in range(3):
        for column in range(3):
            bx = x0 + pad + column * (button_w + pad / 2)
            by = y0 + 205 * s + row * (button_h + 22 * s)
            rounded(draw, (bx, by, bx + button_w, by + button_h), 18 * s, colors[row * 3 + column])

    mcx, mcy = x0 + w - 10 * s, y0 + h - 10 * s
    radius = 120 * s
    draw.ellipse((mcx - radius - 8 * s, mcy - radius - 8 * s, mcx + radius + 8 * s, mcy + radius + 8 * s), fill=(0, 0, 0, 30))
    draw.ellipse((mcx - radius, mcy - radius, mcx + radius, mcy + radius), fill=WHITE)
    rounded(draw, (mcx - 26 * s, mcy - 62 * s, mcx + 26 * s, mcy + 18 * s), 26 * s, ORANGE)
    draw.arc((mcx - 56 * s, mcy - 30 * s, mcx + 56 * s, mcy + 70 * s), 0, 180, fill=ORANGE, width=max(2, int(13 * s)))
    draw.rectangle((mcx - 7 * s, mcy + 70 * s, mcx + 7 * s, mcy + 96 * s), fill=ORANGE)
    rounded(draw, (mcx - 32 * s, mcy + 96 * s, mcx + 32 * s, mcy + 108 * s), 6 * s, ORANGE)


def main():
    size = 1024

    # Legacy / iOS icon: full-bleed gradient with a soft glow.
    icon = gradient(size, ORANGE_LIGHT, ORANGE)
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((-260, -300, 700, 640), fill=(255, 255, 255, 28))
    gd.ellipse((520, 600, 1320, 1400), fill=(255, 255, 255, 18))
    icon = Image.alpha_composite(icon.convert("RGBA"), glow)
    draw_mark(icon, size / 2, size / 2 - 8, 0.92)
    icon.convert("RGB").save("assets/icon/app_icon.png")

    # Adaptive foreground: transparent, content inside the 66% safe zone.
    foreground = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_mark(foreground, size / 2, size / 2, 0.62)
    foreground.save("assets/icon/app_icon_foreground.png")

    # Splash mark on transparent background.
    splash = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_mark(splash, size / 2, size / 2, 0.82)
    splash.save("assets/icon/splash_logo.png")

    # Play Store feature graphic 1024x500.
    feature = Image.new("RGB", (1024, 500), ORANGE)
    fd = ImageDraw.Draw(feature, "RGBA")
    for y in range(500):
        fd.line([(0, y), (1024, y)], fill=lerp(ORANGE_LIGHT, ORANGE, y / 499))
    fd.ellipse((-180, -220, 460, 420), fill=(255, 255, 255, 26))
    fd.ellipse((760, 260, 1260, 760), fill=(255, 255, 255, 20))
    draw_mark(feature, 250, 250, 0.55)
    title_font = ImageFont.truetype(FONT_BOLD, 86)
    tagline_font = ImageFont.truetype(FONT, 34)
    fd.text((470, 160), "VaniCalc", font=title_font, fill=WHITE)
    fd.text((474, 268), "Smart Voice Calculator", font=tagline_font, fill=(255, 255, 255, 235))
    fd.text((474, 320), "10 Indian languages · Offline words · Speech", font=ImageFont.truetype(FONT, 26), fill=(255, 255, 255, 210))
    feature.save("docs/store/feature-graphic.png")


if __name__ == "__main__":
    main()
