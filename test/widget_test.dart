import 'package:climanorm/calculators/hvac_calculator.dart';
import 'package:climanorm/main.dart';
import 'package:climanorm/services/pdf_report_service.dart';
import 'package:climanorm/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  group('HvacCalculator Unit Tests', () {
    test('calculates thermal load BTU/h, Frigorías, kW, and tonnage accurately', () {
      const input = ThermalLoadInput(
        area: 30.0,
        areaUnit: AreaUnit.m2,
        ceilingHeightMeters: 2.5,
        climateZone: ClimateZone.hot,
        sunExposure: SunExposure.moderate,
        occupants: 4,
        appliancesWatts: 500.0,
      );

      final result = HvacCalculator.calculateThermalLoad(input);

      // Envelope: 30 * 650 = 19,500 BTU/h
      // Occupants: 4 * 600 = 2,400 BTU/h
      // Appliances: 500 * 3.41214 = 1,706.07 BTU/h
      // Total: ~23,606.07 BTU/h -> Recommended 2.0 Tons (24,000 BTU/h)
      expect(result.envelopeBtu, closeTo(19500.0, 1.0));
      expect(result.occupantsBtu, closeTo(2400.0, 0.1));
      expect(result.appliancesBtu, closeTo(1706.07, 1.0));
      expect(result.totalBtuPerHour, closeTo(23606.07, 2.0));
      expect(result.frigoriasPerHour, closeTo(5948.6, 5.0));
      expect(result.thermalKw, closeTo(6.92, 0.05));
      expect(result.recommendedTons, equals(2.0));
      expect(result.recommendedNominalBtu, equals(24000));
    });

    test('converts ft2 room area and selects 1.0T to 5.0T appropriately', () {
      const smallRoom = ThermalLoadInput(
        area: 120.0,
        areaUnit: AreaUnit.ft2,
        ceilingHeightMeters: 2.5,
        climateZone: ClimateZone.cold,
        sunExposure: SunExposure.low,
        occupants: 1,
        appliancesWatts: 100.0,
      );
      final smallRes = HvacCalculator.calculateThermalLoad(smallRoom);
      expect(smallRes.recommendedTons, equals(1.0));

      const largeRoom = ThermalLoadInput(
        area: 65.0,
        areaUnit: AreaUnit.m2,
        ceilingHeightMeters: 3.2,
        climateZone: ClimateZone.tropical,
        sunExposure: SunExposure.high,
        occupants: 8,
        appliancesWatts: 1500.0,
      );
      final largeRes = HvacCalculator.calculateThermalLoad(largeRoom);
      expect(largeRes.recommendedTons, equals(5.0));
    });

    test('Antoine P-T forward and inverse equations are consistent across all 5 refrigerants', () {
      for (final gas in RefrigerantType.values) {
        const testTempC = 4.0;
        final psig = HvacCalculator.saturationPressurePsig(gas, testTempC);
        expect(psig, greaterThan(20.0));
        final recoveredTempC = HvacCalculator.saturationTemperatureC(gas, psig);
        expect(recoveredTempC, closeTo(testTempC, 0.05));
      }
    });

    test('Superheat and Subcooling diagnostic verdict identifies Undercharged, Optimal, and Overcharged', () {
      // Optimal for R410A (118 PSIG -> ~3.9°C evap, 382 PSIG -> ~44.8°C cond)
      final optimal = HvacCalculator.evaluatePtDiagnostics(
        refrigerant: RefrigerantType.r410a,
        suctionPsig: 118.0,
        liquidPsig: 382.0,
        suctionLineTempC: 12.0, // SH ~ 8.1 K
        liquidLineTempC: 39.0, // SC ~ 5.8 K
      );
      expect(optimal.verdict, equals(ChargeVerdict.optimal));

      // Undercharged (high SH > 12K, low SC < 3K)
      final under = HvacCalculator.evaluatePtDiagnostics(
        refrigerant: RefrigerantType.r410a,
        suctionPsig: 95.0,
        liquidPsig: 320.0,
        suctionLineTempC: 18.0,
        liquidLineTempC: 37.5,
      );
      expect(under.verdict, equals(ChargeVerdict.undercharged));

      // Overcharged (low SH < 4K, high SC > 9K)
      final over = HvacCalculator.evaluatePtDiagnostics(
        refrigerant: RefrigerantType.r410a,
        suctionPsig: 135.0,
        liquidPsig: 430.0,
        suctionLineTempC: 9.0,
        liquidLineTempC: 35.0,
      );
      expect(over.verdict, equals(ChargeVerdict.overcharged));
    });

    test('generates valid signed PDF bytes', () async {
      const input = ThermalLoadInput();
      final res = HvacCalculator.calculateThermalLoad(input);
      final pt = HvacCalculator.evaluatePtDiagnostics(
        refrigerant: RefrigerantType.r32,
        suctionPsig: 121.0,
        liquidPsig: 398.0,
        suctionLineTempC: 12.0,
        liquidLineTempC: 39.0,
      );
      final project = SavedHvacProject(
        id: 'test-1',
        title: 'Sala Servidores',
        clientName: 'DataCorp',
        siteAddress: 'Piso 4',
        timestamp: DateTime(2026, 11, 9),
        thermalInput: input,
        thermalResult: res,
        ptDiagnostic: pt,
      );

      final bytes = await PdfReportService.generateProjectReport(
        project: project,
        profile: const TechnicianProfile(
          technicianName: 'Ing. Ana Torres',
          companyName: 'ClimaPro Engineering',
          licenseNumber: 'EPA-608-PRO',
        ),
      );

      expect(bytes.length, greaterThan(1000));
      // PDF magic header %PDF
      expect(String.fromCharCodes(bytes.sublist(0, 4)), equals('%PDF'));
    });
  });

  group('ClimaNorm Widget & Navigation E2E Tests', () {
    testWidgets('boots into WelcomeLandingScreen, enters 4-tab HomeNavigationScreen, and switches languages',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ClimaNormApp());
      await tester.pumpAndSettle();

      // Verify WelcomeLandingScreen
      expect(find.text('CLIMANORM PRO'), findsOneWidget);
      final enterBtn = find.byKey(const Key('btnWelcomeEnter'));
      expect(enterBtn, findsOneWidget);

      // Tap Enter button
      await tester.tap(enterBtn);
      await tester.pumpAndSettle();

      // Tab 0: BTU Thermal Load Calculator with CustomPaint gauge
      expect(find.byKey(const Key('btuGaugeCustomPaint')), findsOneWidget);
      expect(find.byKey(const Key('txtTotalBtuResult')), findsOneWidget);

      // Navigate to Tab 1: P-T Diagnostics
      await tester.tap(find.byKey(const Key('navTab_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ptCurveCustomPaint')), findsOneWidget);
      expect(find.byKey(const Key('chipGas_r32')), findsOneWidget);

      // Select R-32 refrigerant
      await tester.tap(find.byKey(const Key('chipGas_r32')));
      await tester.pumpAndSettle();
      expect(find.textContaining('R-32'), findsWidgets);

      // Navigate to Tab 2: Saved HVAC Projects
      await tester.tap(find.byKey(const Key('navTab_2')));
      await tester.pumpAndSettle();

      // Navigate to Tab 3: Settings & test 1-tap ES/EN/PT switcher
      await tester.tap(find.byKey(const Key('navTab_3')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('langOption_en')));
      await tester.pumpAndSettle();
      expect(StorageService.instance.localeCode, equals('en'));
      expect(find.text('Settings & Tech Profile'), findsOneWidget);

      await tester.tap(find.byKey(const Key('langOption_pt')));
      await tester.pumpAndSettle();
      expect(StorageService.instance.localeCode, equals('pt'));
    });
  });
}
