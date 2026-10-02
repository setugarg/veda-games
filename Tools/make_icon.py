"""Draws the pastel Tiffy app icon. Run: python3 Tools/make_icon.py (needs Pillow)."""
from PIL import Image, ImageDraw

S = 1024
img = Image.new("RGB", (S, S), (255, 226, 207))
d = ImageDraw.Draw(img)

# Soft background blobs
d.ellipse((-200, -260, 620, 520), fill=(227, 219, 246))
d.ellipse((520, 560, 1240, 1260), fill=(213, 240, 223))

steel, edge, ink, rose = (232, 235, 242), (170, 177, 196), (75, 63, 92), (231, 163, 181)

# Handle
d.rounded_rectangle((372, 150, 652, 420), radius=140, outline=edge, width=34)
# Tiers
tiers = [(250, 330, 774, 480), (230, 495, 794, 720), (250, 735, 774, 885)]
for box in tiers:
    d.rounded_rectangle(box, radius=70, fill=steel, outline=edge, width=18)
# Face on middle tier
d.ellipse((400, 560, 450, 610), fill=ink)
d.ellipse((574, 560, 624, 610), fill=ink)
d.arc((452, 580, 572, 670), start=20, end=160, fill=ink, width=16)
d.ellipse((340, 615, 395, 655), fill=rose)
d.ellipse((629, 615, 684, 655), fill=rose)
# Leaf sprout on top
d.ellipse((520, 90, 640, 160), fill=(143, 207, 170))

img.save("TiffinTales/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
