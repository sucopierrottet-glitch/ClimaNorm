# ClimaNorm Pro — HVAC Thermal Load & P-T Diagnostic Suite

**ClimaNorm Pro** (`com.simpleappspg.climanorm`) is an offline-first Flutter engineering application built by **SimpleApps PG** for HVAC&R technicians, mechanical engineers, and contractors.

## Key Features
1. **HVAC Thermal Load Calculator (`lib/calculators/hvac_calculator.dart`)**:
   - Supports room area in $m^2$ or $ft^2$, ceiling height, climate zones (Cold, Temperate, Hot, Tropical), sun exposure (Low, Moderate, High), occupants, and internal electrical loads (W).
   - Computes Total BTU/h, Frigorías/h, thermal power (kW), exact refrigeration tonnage, and recommended commercial equipment tonnage (`1.0T`, `1.5T`, `2.0T`, `3.0T`, `5.0T`).
   - Interactive radial BTU/h & Tonnage Gauge rendered via `CustomPainter` (`BtuGaugePainter`).
2. **Refrigerant P-T & Superheat/Subcooling Diagnostics**:
   - Supports **R-32**, **R-410A**, **R-134a**, **R-404A**, and **R-22** via calibrated Antoine saturation equations.
   - Real-time Evaporator & Condenser saturation temperatures, Superheat (SH), Subcooling (SC), and automatic charge verdict (`Undercharged`, `Optimal`, `Overcharged`).
   - Live P-T saturation curve chart (`PtChartPainter`).
3. **Signed PDF Technical Reports**:
   - Generates A4 engineering reports (`pdf` + `printing`) with digital touch signature capture (`signature`).
4. **Trilingual & Offline-First**:
   - Instant 1-tap language switcher (`es`, `en`, `pt`) persisted via `SharedPreferences`.
   - SimpleAppsPG Obsidian Dark Theme (`#0B0F19`, `#161F30`, `#38BDF8`, `#00E676`) with zero network font requests.
