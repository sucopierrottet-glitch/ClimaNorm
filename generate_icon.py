import math
import os
from PIL import Image, ImageDraw

def create_app_icon(output_path="assets/icon/app_icon.png"):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Base Rounded Squircle (SimpleAppsPG Obsidian Dark Gradient)
    bg_margin = 32
    bg_radius = 220

    gradient_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    grad_draw = ImageDraw.Draw(gradient_img)

    for y in range(size):
        ratio = y / size
        r = int(11 + (22 - 11) * ratio)
        g = int(15 + (31 - 15) * ratio)
        b = int(25 + (48 - 25) * ratio)
        grad_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin],
        radius=bg_radius,
        fill=255,
    )
    img.paste(gradient_img, (0, 0), mask)

    # Outer ice-blue subtle rim
    draw.rounded_rectangle(
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin],
        radius=bg_radius,
        outline=(56, 189, 248, 95),
        width=6,
    )

    cx, cy = 512, 512
    outer_r = 365
    inner_r = 305

    # 2. HVAC Manifold Gauge Bezel
    draw.ellipse(
        [cx - outer_r, cy - outer_r, cx + outer_r, cy + outer_r],
        fill=(22, 31, 48, 255),
        outline=(56, 189, 248, 220),
        width=10,
    )
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=(11, 15, 25, 255),
        outline=(0, 230, 118, 200),
        width=8,
    )

    # Calibration ticks around gauge
    for deg in range(135, 406, 15):
        rad = math.radians(deg)
        r1 = inner_r - 28 if deg % 45 == 0 else inner_r - 16
        r2 = inner_r - 4
        x1, y1 = cx + r1 * math.cos(rad), cy + r1 * math.sin(rad)
        x2, y2 = cx + r2 * math.cos(rad), cy + r2 * math.sin(rad)
        col = (0, 230, 118, 255) if deg >= 270 else (56, 189, 248, 255)
        draw.line([(x1, y1), (x2, y2)], fill=col, width=6 if deg % 45 == 0 else 3)

    # 3. Central Geometric HVAC Snowflake Crystal (#38BDF8 Ice Blue)
    flake_r = 185
    branch_offset = 105
    branch_len = 52
    ice_col = (56, 189, 248, 255)

    for i in range(6):
        angle = math.radians(i * 60 - 90)
        ex = cx + flake_r * math.cos(angle)
        ey = cy + flake_r * math.sin(angle)
        draw.line([(cx, cy), (ex, ey)], fill=ice_col, width=16)
        draw.ellipse([ex - 10, ey - 10, ex + 10, ey + 10], fill=(248, 250, 252, 255))

        # Side crystal chevrons
        bx = cx + branch_offset * math.cos(angle)
        by = cy + branch_offset * math.sin(angle)
        for delta in (-45, 45):
            b_ang = angle + math.radians(delta)
            tx = bx + branch_len * math.cos(b_ang)
            ty = by + branch_len * math.sin(b_ang)
            draw.line([(bx, by), (tx, ty)], fill=ice_col, width=11)

    # Center hub with compliant green ring
    draw.ellipse([cx - 46, cy - 46, cx + 46, cy + 46], fill=(15, 23, 42, 255), outline=(0, 230, 118, 255), width=8)
    draw.ellipse([cx - 18, cy - 18, cx + 18, cy + 18], fill=(0, 230, 118, 255))

    img.save(output_path, "PNG")
    print(f"Generated ClimaNorm Pro icon successfully at {output_path}")

if __name__ == "__main__":
    create_app_icon()
