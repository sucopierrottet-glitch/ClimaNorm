# 🚀 Guía de Publicación en Tiendas: ClimaNorm Pro (`com.simpleappspg.climanorm`)

## 📦 1. Resumen de Configuración (Camino 1 — Paid App 100% Pro Unlocked)
- **Nombre de la App**: `ClimaNorm Pro: Carga BTU & P-T HVAC`
- **Package ID / Namespace**: `com.simpleappspg.climanorm`
- **Modelo de Monetización**: Camino 1 — Aplicación de Pago Único ($3.99 USD) en Google Play y App Store, 100% desbloqueada desde el primer inicio, sin anuncios, sin suscripciones ni paywalls bloqueantes.
- **Idiomas incluidos**: Español (`es`), Inglés (`en`), Portugués (`pt`) con cambio instantáneo en 1 toque.

## 🎨 2. Recursos Gráficos Generados (`store_assets/`)
- `assets/icon/app_icon.png` (1024x1024 px) + íconos adaptativos Android/iOS generados con `flutter_launcher_icons`.
- `store_assets/icon_512.png` (512x512 px para Google Play Console).
- `store_assets/feature_graphic_1024x500.png` (1024x500 px Feature Graphic).
- `store_assets/1_pantalla_bienvenida.png` a `4_memoria_tecnica_pdf.png` (Capturas 1080x1920 px).

## 🛠️ 3. Comandos de Verificación y Compilación
```bash
python generate_icon.py
dart run flutter_launcher_icons
python generate_store_assets.py
flutter analyze
flutter test
flutter build appbundle --release
```
