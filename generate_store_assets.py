import os
from PIL import Image, ImageDraw, ImageFont

def generate_store_assets():
    out_dir = "store_assets"
    os.makedirs(out_dir, exist_ok=True)

    font_bold_path = "C:/Windows/Fonts/segoeuib.ttf"
    font_reg_path = "C:/Windows/Fonts/segoeui.ttf"

    base_icon_path = "assets/icon/app_icon.png"
    if os.path.exists(base_icon_path):
        base_icon = Image.open(base_icon_path).convert("RGBA")
        icon_512 = base_icon.resize((512, 512), Image.Resampling.LANCZOS)
        icon_512.save(os.path.join(out_dir, "icon_512.png"), "PNG")
        print("Generated icon_512.png")

    # Feature Graphic 1024x500
    w_feat, h_feat = 1024, 500
    feat_img = Image.new("RGBA", (w_feat, h_feat), (11, 15, 25, 255))
    feat_draw = ImageDraw.Draw(feat_img)

    for x in range(w_feat):
        ratio = x / w_feat
        r = int(11 + (22 - 11) * ratio)
        g = int(15 + (31 - 15) * ratio)
        b = int(25 + (48 - 25) * ratio)
        feat_draw.line([(x, 0), (x, h_feat)], fill=(r, g, b, 255))

    if os.path.exists(base_icon_path):
        icon_for_feat = Image.open(base_icon_path).convert("RGBA").resize((320, 320), Image.Resampling.LANCZOS)
        feat_img.paste(icon_for_feat, (85, 90), icon_for_feat)

    f_badge = ImageFont.truetype(font_bold_path, 15)
    f_title = ImageFont.truetype(font_bold_path, 46)
    f_sub = ImageFont.truetype(font_reg_path, 21)
    f_tag = ImageFont.truetype(font_bold_path, 14)

    tx = 450
    feat_draw.rounded_rectangle([tx, 95, tx + 390, 130], radius=18, fill=(56, 189, 248, 35), outline=(56, 189, 248, 190), width=1)
    feat_draw.text((tx + 16, 103), "INGENIERÍA HVAC • ASHRAE & RITE", font=f_badge, fill=(56, 189, 248, 255))
    feat_draw.text((tx, 145), "CLIMANORM PRO", font=f_title, fill=(248, 250, 252, 255))
    feat_draw.text((tx, 210), "Carga Térmica BTU/h • Tablas P-T Refrigerantes", font=f_sub, fill=(203, 213, 225, 255))
    feat_draw.text((tx, 242), "Recalentamiento, Subenfriamiento & Reportes PDF", font=f_sub, fill=(148, 163, 184, 255))

    chips = ["R32 / R410A / R134a", "R404A / R22", "BTU & FRIGORÍAS", "100% OFFLINE"]
    cx = tx
    cy = 305
    for c in chips:
        bbox = f_tag.getbbox(c)
        tw = bbox[2] - bbox[0] + 24
        feat_draw.rounded_rectangle([cx, cy, cx + tw, cy + 32], radius=8, fill=(22, 31, 48, 255), outline=(45, 60, 82, 255), width=1)
        feat_draw.text((cx + 12, cy + 7), c, font=f_tag, fill=(0, 230, 118, 255))
        cx += tw + 10
        if cx > 940:
            cx = tx
            cy += 42

    feat_img.save(os.path.join(out_dir, "feature_graphic_1024x500.png"), "PNG")
    print("Generated feature_graphic_1024x500.png")

    def create_screenshot(filename, tag, title, sub, body_title, metric_big, metric_sub):
        w, h = 1080, 1920
        img = Image.new("RGBA", (w, h), (11, 15, 25, 255))
        draw = ImageDraw.Draw(img)

        f_top_tag = ImageFont.truetype(font_bold_path, 28)
        f_top_title = ImageFont.truetype(font_bold_path, 60)
        f_top_sub = ImageFont.truetype(font_reg_path, 32)
        f_card_h = ImageFont.truetype(font_bold_path, 34)
        f_big = ImageFont.truetype(font_bold_path, 68)

        draw.text((70, 90), tag.upper(), font=f_top_tag, fill=(56, 189, 248, 255))
        draw.text((70, 138), title, font=f_top_title, fill=(248, 250, 252, 255))
        draw.text((70, 218), sub, font=f_top_sub, fill=(148, 163, 184, 255))

        p_left, p_top, p_right, p_bottom = 80, 310, 1000, 1850
        draw.rounded_rectangle([p_left, p_top, p_right, p_bottom], radius=52, fill=(16, 23, 37, 255), outline=(56, 189, 248, 120), width=4)
        draw.rounded_rectangle([p_left + 36, p_top + 90, p_right - 36, p_top + 560], radius=24, fill=(22, 31, 48, 255), outline=(0, 230, 118, 180), width=2)
        draw.text((p_left + 70, p_top + 130), body_title, font=f_card_h, fill=(56, 189, 248, 255))
        draw.text((p_left + 70, p_top + 220), metric_big, font=f_big, fill=(255, 255, 255, 255))
        draw.text((p_left + 70, p_top + 330), metric_sub, font=f_top_sub, fill=(0, 230, 118, 255))

        img.save(os.path.join(out_dir, filename), "PNG")
        print(f"Generated {filename}")

    create_screenshot(
        "1_pantalla_bienvenida.png",
        "ClimaNorm Pro • Sin Anuncios",
        "Ingeniería HVAC en Campo",
        "100% Pro Desbloqueado y Offline-First",
        "CLIMANORM PRO EDITION",
        "BTU/h & P-T",
        "ASHRAE • ISO 5151 • RITE • EPA 608",
    )
    create_screenshot(
        "2_carga_termica_btu.png",
        "Dimensionamiento Exacto",
        "Calculadora de Carga Térmica",
        "BTU/h, Frigorías, kW y Tonelaje Recomendado",
        "CARGA TÉRMICA TOTAL REQUERIDA",
        "21,540 BTU/h",
        "Equipo Recomendado: 2.0 Ton (5,428 fg/h | 6.31 kW)",
    )
    create_screenshot(
        "3_diagnostico_pt_gases.png",
        "Termodinámica de Gases",
        "Curvas P-T & Diagnóstico SH/SC",
        "R32, R410A, R134a, R404A y R22 con ecuaciones de Antoine",
        "DIAGNÓSTICO R-410A (118 / 382 PSIG)",
        "SH: 8.1 K | SC: 5.9 K",
        "✓ CARGA ÓPTIMA (DENTRO DE NORMA ASHRAE)",
    )
    create_screenshot(
        "4_memoria_tecnica_pdf.png",
        "Reportes Ejecutivos",
        "Memorias Técnicas PDF Firmadas",
        "Firma digital en pantalla lista para entregar al cliente",
        "MEMORIA DE CÁLCULO HVAC FIRMADA",
        "PDF + FIRMA",
        "Exportación directa A4 con tablas térmicas y P-T",
    )

if __name__ == "__main__":
    generate_store_assets()
