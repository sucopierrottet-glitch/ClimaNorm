import 'dart:math' as math;

enum AreaUnit { m2, ft2 }

enum ClimateZone { cold, temperate, hot, tropical }

enum SunExposure { low, moderate, high }

enum RefrigerantType { r32, r410a, r134a, r404a, r22 }

enum ChargeVerdict { undercharged, optimal, overcharged }

class ThermalLoadInput {
  final double area;
  final AreaUnit areaUnit;
  final double ceilingHeightMeters;
  final ClimateZone climateZone;
  final SunExposure sunExposure;
  final int occupants;
  final double appliancesWatts;

  const ThermalLoadInput({
    this.area = 28.0,
    this.areaUnit = AreaUnit.m2,
    this.ceilingHeightMeters = 2.6,
    this.climateZone = ClimateZone.hot,
    this.sunExposure = SunExposure.moderate,
    this.occupants = 3,
    this.appliancesWatts = 450.0,
  });

  double get areaM2 =>
      areaUnit == AreaUnit.m2 ? area : area * 0.09290304;

  double get areaFt2 =>
      areaUnit == AreaUnit.ft2 ? area : area * 10.7639104;

  ThermalLoadInput copyWith({
    double? area,
    AreaUnit? areaUnit,
    double? ceilingHeightMeters,
    ClimateZone? climateZone,
    SunExposure? sunExposure,
    int? occupants,
    double? appliancesWatts,
  }) {
    return ThermalLoadInput(
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      ceilingHeightMeters: ceilingHeightMeters ?? this.ceilingHeightMeters,
      climateZone: climateZone ?? this.climateZone,
      sunExposure: sunExposure ?? this.sunExposure,
      occupants: occupants ?? this.occupants,
      appliancesWatts: appliancesWatts ?? this.appliancesWatts,
    );
  }

  Map<String, dynamic> toJson() => {
        'area': area,
        'areaUnit': areaUnit.name,
        'ceilingHeightMeters': ceilingHeightMeters,
        'climateZone': climateZone.name,
        'sunExposure': sunExposure.name,
        'occupants': occupants,
        'appliancesWatts': appliancesWatts,
      };

  factory ThermalLoadInput.fromJson(Map<String, dynamic> json) {
    return ThermalLoadInput(
      area: (json['area'] as num?)?.toDouble() ?? 28.0,
      areaUnit: AreaUnit.values.firstWhere(
        (e) => e.name == json['areaUnit'],
        orElse: () => AreaUnit.m2,
      ),
      ceilingHeightMeters:
          (json['ceilingHeightMeters'] as num?)?.toDouble() ?? 2.6,
      climateZone: ClimateZone.values.firstWhere(
        (e) => e.name == json['climateZone'],
        orElse: () => ClimateZone.hot,
      ),
      sunExposure: SunExposure.values.firstWhere(
        (e) => e.name == json['sunExposure'],
        orElse: () => SunExposure.moderate,
      ),
      occupants: (json['occupants'] as num?)?.toInt() ?? 3,
      appliancesWatts: (json['appliancesWatts'] as num?)?.toDouble() ?? 450.0,
    );
  }
}

class ThermalLoadResult {
  final double envelopeBtu;
  final double occupantsBtu;
  final double appliancesBtu;
  final double totalBtuPerHour;
  final double frigoriasPerHour;
  final double thermalKw;
  final double exactTons;
  final double recommendedTons;
  final int recommendedNominalBtu;
  final double capacityUtilizationPercent;

  const ThermalLoadResult({
    required this.envelopeBtu,
    required this.occupantsBtu,
    required this.appliancesBtu,
    required this.totalBtuPerHour,
    required this.frigoriasPerHour,
    required this.thermalKw,
    required this.exactTons,
    required this.recommendedTons,
    required this.recommendedNominalBtu,
    required this.capacityUtilizationPercent,
  });

  Map<String, dynamic> toJson() => {
        'envelopeBtu': envelopeBtu,
        'occupantsBtu': occupantsBtu,
        'appliancesBtu': appliancesBtu,
        'totalBtuPerHour': totalBtuPerHour,
        'frigoriasPerHour': frigoriasPerHour,
        'thermalKw': thermalKw,
        'exactTons': exactTons,
        'recommendedTons': recommendedTons,
        'recommendedNominalBtu': recommendedNominalBtu,
        'capacityUtilizationPercent': capacityUtilizationPercent,
      };

  factory ThermalLoadResult.fromJson(Map<String, dynamic> json) {
    return ThermalLoadResult(
      envelopeBtu: (json['envelopeBtu'] as num?)?.toDouble() ?? 0.0,
      occupantsBtu: (json['occupantsBtu'] as num?)?.toDouble() ?? 0.0,
      appliancesBtu: (json['appliancesBtu'] as num?)?.toDouble() ?? 0.0,
      totalBtuPerHour: (json['totalBtuPerHour'] as num?)?.toDouble() ?? 0.0,
      frigoriasPerHour: (json['frigoriasPerHour'] as num?)?.toDouble() ?? 0.0,
      thermalKw: (json['thermalKw'] as num?)?.toDouble() ?? 0.0,
      exactTons: (json['exactTons'] as num?)?.toDouble() ?? 0.0,
      recommendedTons: (json['recommendedTons'] as num?)?.toDouble() ?? 1.0,
      recommendedNominalBtu:
          (json['recommendedNominalBtu'] as num?)?.toInt() ?? 12000,
      capacityUtilizationPercent:
          (json['capacityUtilizationPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RefrigerantSpec {
  final RefrigerantType type;
  final String code;
  final String chemicalName;
  final String safetyClass;
  final int gwp;
  final double antoineA;
  final double antoineB;
  final double antoineC;
  final double defaultSuctionPsig;
  final double defaultLiquidPsig;

  const RefrigerantSpec({
    required this.type,
    required this.code,
    required this.chemicalName,
    required this.safetyClass,
    required this.gwp,
    required this.antoineA,
    required this.antoineB,
    required this.antoineC,
    required this.defaultSuctionPsig,
    required this.defaultLiquidPsig,
  });
}

class PtDiagnosticResult {
  final RefrigerantType refrigerant;
  final double suctionPsig;
  final double liquidPsig;
  final double suctionLineTempC;
  final double liquidLineTempC;
  final double evapSatTempC;
  final double condSatTempC;
  final double superheatK;
  final double subcoolingK;
  final ChargeVerdict verdict;

  const PtDiagnosticResult({
    required this.refrigerant,
    required this.suctionPsig,
    required this.liquidPsig,
    required this.suctionLineTempC,
    required this.liquidLineTempC,
    required this.evapSatTempC,
    required this.condSatTempC,
    required this.superheatK,
    required this.subcoolingK,
    required this.verdict,
  });

  Map<String, dynamic> toJson() => {
        'refrigerant': refrigerant.name,
        'suctionPsig': suctionPsig,
        'liquidPsig': liquidPsig,
        'suctionLineTempC': suctionLineTempC,
        'liquidLineTempC': liquidLineTempC,
        'evapSatTempC': evapSatTempC,
        'condSatTempC': condSatTempC,
        'superheatK': superheatK,
        'subcoolingK': subcoolingK,
        'verdict': verdict.name,
      };

  factory PtDiagnosticResult.fromJson(Map<String, dynamic> json) {
    return PtDiagnosticResult(
      refrigerant: RefrigerantType.values.firstWhere(
        (e) => e.name == json['refrigerant'],
        orElse: () => RefrigerantType.r410a,
      ),
      suctionPsig: (json['suctionPsig'] as num?)?.toDouble() ?? 118.0,
      liquidPsig: (json['liquidPsig'] as num?)?.toDouble() ?? 380.0,
      suctionLineTempC: (json['suctionLineTempC'] as num?)?.toDouble() ?? 12.0,
      liquidLineTempC: (json['liquidLineTempC'] as num?)?.toDouble() ?? 39.0,
      evapSatTempC: (json['evapSatTempC'] as num?)?.toDouble() ?? 4.0,
      condSatTempC: (json['condSatTempC'] as num?)?.toDouble() ?? 45.0,
      superheatK: (json['superheatK'] as num?)?.toDouble() ?? 8.0,
      subcoolingK: (json['subcoolingK'] as num?)?.toDouble() ?? 6.0,
      verdict: ChargeVerdict.values.firstWhere(
        (e) => e.name == json['verdict'],
        orElse: () => ChargeVerdict.optimal,
      ),
    );
  }
}

/// Deterministic ASHRAE / ISO 5151 / RITE HVAC Calculator Engine
class HvacCalculator {
  static const List<double> standardTonnages = [1.0, 1.5, 2.0, 3.0, 5.0];

  static const Map<RefrigerantType, RefrigerantSpec> refrigerants = {
    RefrigerantType.r32: RefrigerantSpec(
      type: RefrigerantType.r32,
      code: 'R-32',
      chemicalName: 'Difluoromethane (HFC-32)',
      safetyClass: 'A2L',
      gwp: 675,
      antoineA: 4.410,
      antoineB: 860.0,
      antoineC: 246.0,
      defaultSuctionPsig: 121.0,
      defaultLiquidPsig: 398.0,
    ),
    RefrigerantType.r410a: RefrigerantSpec(
      type: RefrigerantType.r410a,
      code: 'R-410A',
      chemicalName: 'R-32 / R-125 (50/50 wt%)',
      safetyClass: 'A1',
      gwp: 2088,
      antoineA: 4.345,
      antoineB: 845.0,
      antoineC: 246.0,
      defaultSuctionPsig: 118.0,
      defaultLiquidPsig: 382.0,
    ),
    RefrigerantType.r134a: RefrigerantSpec(
      type: RefrigerantType.r134a,
      code: 'R-134a',
      chemicalName: '1,1,1,2-Tetrafluoroethane',
      safetyClass: 'A1',
      gwp: 1430,
      antoineA: 4.160,
      antoineB: 905.0,
      antoineC: 245.0,
      defaultSuctionPsig: 34.0,
      defaultLiquidPsig: 145.0,
    ),
    RefrigerantType.r404a: RefrigerantSpec(
      type: RefrigerantType.r404a,
      code: 'R-404A',
      chemicalName: 'R-125 / R-143a / R-134a',
      safetyClass: 'A1',
      gwp: 3922,
      antoineA: 4.195,
      antoineB: 838.0,
      antoineC: 245.0,
      defaultSuctionPsig: 83.0,
      defaultLiquidPsig: 278.0,
    ),
    RefrigerantType.r22: RefrigerantSpec(
      type: RefrigerantType.r22,
      code: 'R-22',
      chemicalName: 'Chlorodifluoromethane (HCFC-22)',
      safetyClass: 'A1',
      gwp: 1810,
      antoineA: 4.105,
      antoineB: 835.0,
      antoineC: 245.0,
      defaultSuctionPsig: 67.0,
      defaultLiquidPsig: 230.0,
    ),
  };

  static RefrigerantSpec getSpec(RefrigerantType type) =>
      refrigerants[type] ?? refrigerants[RefrigerantType.r410a]!;

  /// Calculates total room cooling thermal load in BTU/h, Frigorías, kW, and recommended tonnage.
  static ThermalLoadResult calculateThermalLoad(ThermalLoadInput input) {
    final safeAreaM2 = input.areaM2.clamp(1.0, 5000.0);
    final safeHeightM = input.ceilingHeightMeters.clamp(1.8, 12.0);
    final safeOccupants = input.occupants.clamp(0, 500);
    final safeWatts = input.appliancesWatts.clamp(0.0, 500000.0);

    // Base BTU/h per m² depending on Climate Zone (ASHRAE / Carrier simplified load factor)
    final double baseBtuPerM2 = switch (input.climateZone) {
      ClimateZone.cold => 450.0,
      ClimateZone.temperate => 550.0,
      ClimateZone.hot => 650.0,
      ClimateZone.tropical => 780.0,
    };

    // Sun exposure multiplier
    final double sunMultiplier = switch (input.sunExposure) {
      SunExposure.low => 0.90,
      SunExposure.moderate => 1.00,
      SunExposure.high => 1.15,
    };

    // Ceiling height volumetric factor (normalized to 2.5m standard ceiling)
    final double heightFactor =
        safeHeightM <= 2.5 ? 1.0 : 1.0 + ((safeHeightM - 2.5) * 0.12);

    final double envelopeBtu =
        safeAreaM2 * baseBtuPerM2 * sunMultiplier * heightFactor;

    // Occupants latent + sensible heat (~600 BTU/h per person)
    final double occupantsBtu = safeOccupants * 600.0;

    // Electrical & lighting equipment heat gain (1 W = 3.41214163 BTU/h)
    final double appliancesBtu = safeWatts * 3.41214163;

    final double totalBtu = envelopeBtu + occupantsBtu + appliancesBtu;
    final double frigorias = totalBtu / 3.96832;
    final double kw = totalBtu / 3412.14163;
    final double exactTons = totalBtu / 12000.0;

    // Select commercial standard tonnage from [1.0, 1.5, 2.0, 3.0, 5.0]
    double recTons = standardTonnages.last;
    for (final ton in standardTonnages) {
      if (exactTons <= ton + 0.05) {
        recTons = ton;
        break;
      }
    }

    final int recNominalBtu = (recTons * 12000).round();
    final double utilization =
        ((totalBtu / recNominalBtu) * 100.0).clamp(0.0, 150.0);

    return ThermalLoadResult(
      envelopeBtu: envelopeBtu,
      occupantsBtu: occupantsBtu,
      appliancesBtu: appliancesBtu,
      totalBtuPerHour: totalBtu,
      frigoriasPerHour: frigorias,
      thermalKw: kw,
      exactTons: exactTons,
      recommendedTons: recTons,
      recommendedNominalBtu: recNominalBtu,
      capacityUtilizationPercent: utilization,
    );
  }

  /// Calculates gauge saturation pressure (PSIG) for a given saturation temperature (°C)
  /// using the refrigerant's calibrated Antoine equation: log10(P_bar_abs) = A - B / (T_C + C)
  static double saturationPressurePsig(RefrigerantType type, double tempC) {
    final spec = getSpec(type);
    final clampedT = tempC.clamp(-50.0, 75.0);
    final log10PBar =
        spec.antoineA - (spec.antoineB / (clampedT + spec.antoineC));
    final pBarAbs = math.pow(10.0, log10PBar).toDouble();
    final psig = (pBarAbs - 1.01325) * 14.5037738;
    return math.max(0.0, psig);
  }

  /// Inverse Antoine equation: calculates saturation temperature (°C) from gauge pressure (PSIG).
  static double saturationTemperatureC(RefrigerantType type, double psig) {
    final spec = getSpec(type);
    final safePsig = math.max(0.5, psig);
    final pBarAbs = (safePsig / 14.5037738) + 1.01325;
    final log10PBar = math.log(pBarAbs) / math.ln10;
    final tempC = (spec.antoineB / (spec.antoineA - log10PBar)) - spec.antoineC;
    return tempC.clamp(-60.0, 85.0);
  }

  /// Evaluates Superheat (SH), Subcooling (SC), and charge verdict.
  /// Optimal Superheat: 4.0 K to 12.0 K; Optimal Subcooling: 3.0 K to 9.0 K.
  static PtDiagnosticResult evaluatePtDiagnostics({
    required RefrigerantType refrigerant,
    required double suctionPsig,
    required double liquidPsig,
    required double suctionLineTempC,
    required double liquidLineTempC,
  }) {
    final evapSatC = saturationTemperatureC(refrigerant, suctionPsig);
    final condSatC = saturationTemperatureC(refrigerant, liquidPsig);

    final superheatK = math.max(0.0, suctionLineTempC - evapSatC);
    final subcoolingK = math.max(0.0, condSatC - liquidLineTempC);

    final ChargeVerdict verdict;
    if (superheatK > 12.0 || subcoolingK < 3.0) {
      verdict = ChargeVerdict.undercharged;
    } else if (superheatK < 4.0 || subcoolingK > 9.0) {
      verdict = ChargeVerdict.overcharged;
    } else {
      verdict = ChargeVerdict.optimal;
    }

    return PtDiagnosticResult(
      refrigerant: refrigerant,
      suctionPsig: suctionPsig,
      liquidPsig: liquidPsig,
      suctionLineTempC: suctionLineTempC,
      liquidLineTempC: liquidLineTempC,
      evapSatTempC: evapSatC,
      condSatTempC: condSatC,
      superheatK: superheatK,
      subcoolingK: subcoolingK,
      verdict: verdict,
    );
  }
}
