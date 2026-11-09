import 'package:flutter/material.dart';

import '../calculators/hvac_calculator.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pt_chart_painter.dart';

class PtDiagnosticScreen extends StatefulWidget {
  const PtDiagnosticScreen({super.key});

  @override
  State<PtDiagnosticScreen> createState() => _PtDiagnosticScreenState();
}

class _PtDiagnosticScreenState extends State<PtDiagnosticScreen> {
  RefrigerantType _selectedGas = RefrigerantType.r410a;
  final _suctionPsigCtrl = TextEditingController(text: '118');
  final _suctionTempCtrl = TextEditingController(text: '12.0');
  final _liquidPsigCtrl = TextEditingController(text: '382');
  final _liquidTempCtrl = TextEditingController(text: '39.0');

  @override
  void dispose() {
    _suctionPsigCtrl.dispose();
    _suctionTempCtrl.dispose();
    _liquidPsigCtrl.dispose();
    _liquidTempCtrl.dispose();
    super.dispose();
  }

  void _selectRefrigerant(RefrigerantType gas) {
    final spec = HvacCalculator.getSpec(gas);
    final evapSat = HvacCalculator.saturationTemperatureC(
      gas,
      spec.defaultSuctionPsig,
    );
    final condSat = HvacCalculator.saturationTemperatureC(
      gas,
      spec.defaultLiquidPsig,
    );
    setState(() {
      _selectedGas = gas;
      _suctionPsigCtrl.text = spec.defaultSuctionPsig.toStringAsFixed(0);
      _suctionTempCtrl.text = (evapSat + 8.0).toStringAsFixed(1);
      _liquidPsigCtrl.text = spec.defaultLiquidPsig.toStringAsFixed(0);
      _liquidTempCtrl.text = (condSat - 6.0).toStringAsFixed(1);
    });
  }

  Color _gasColor(RefrigerantType gas) {
    return switch (gas) {
      RefrigerantType.r32 => AppColors.r32Color,
      RefrigerantType.r410a => AppColors.r410aColor,
      RefrigerantType.r134a => AppColors.r134aColor,
      RefrigerantType.r404a => AppColors.r404aColor,
      RefrigerantType.r22 => AppColors.r22Color,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;
        final spec = HvacCalculator.getSpec(_selectedGas);
        final suctionPsig =
            double.tryParse(_suctionPsigCtrl.text.trim()) ??
            spec.defaultSuctionPsig;
        final suctionTemp =
            double.tryParse(_suctionTempCtrl.text.trim()) ?? 12.0;
        final liquidPsig =
            double.tryParse(_liquidPsigCtrl.text.trim()) ??
            spec.defaultLiquidPsig;
        final liquidTemp = double.tryParse(_liquidTempCtrl.text.trim()) ?? 39.0;

        final diag = HvacCalculator.evaluatePtDiagnostics(
          refrigerant: _selectedGas,
          suctionPsig: suctionPsig,
          liquidPsig: liquidPsig,
          suctionLineTempC: suctionTemp,
          liquidLineTempC: liquidTemp,
        );

        final (verdictColor, verdictTitle, verdictDesc) = switch (diag.verdict) {
          ChargeVerdict.undercharged => (
            AppColors.caution,
            s.verdictUndercharged,
            s.verdictDescUndercharged,
          ),
          ChargeVerdict.optimal => (
            AppColors.compliant,
            s.verdictOptimal,
            s.verdictDescOptimal,
          ),
          ChargeVerdict.overcharged => (
            AppColors.critical,
            s.verdictOvercharged,
            s.verdictDescOvercharged,
          ),
        };

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(
                  Icons.speed_rounded,
                  color: AppColors.compliant,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.ptScreenTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Refrigerant Selector Chips
                Text(
                  s.selectRefrigerantLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RefrigerantType.values.map((gas) {
                    final gSpec = HvacCalculator.getSpec(gas);
                    final selected = gas == _selectedGas;
                    final col = _gasColor(gas);
                    return ChoiceChip(
                      key: Key('chipGas_${gas.name}'),
                      label: Text(
                        '${gSpec.code} (${gSpec.safetyClass})',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: selected ? Colors.black : Colors.white,
                        ),
                      ),
                      selected: selected,
                      selectedColor: col,
                      backgroundColor: AppColors.surfaceCard,
                      side: BorderSide(color: col),
                      onSelected: (_) => _selectRefrigerant(gas),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 2. P-T Saturation Curve Chart + Live SH/SC Readouts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _gasColor(_selectedGas).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${spec.code} — ${spec.chemicalName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _gasColor(_selectedGas),
                            ),
                          ),
                          Text(
                            'GWP ${spec.gwp} • ASHRAE ${spec.safetyClass}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: CustomPaint(
                          key: const Key('ptCurveCustomPaint'),
                          painter: PtChartPainter(
                            refrigerant: _selectedGas,
                            evapSatTempC: diag.evapSatTempC,
                            suctionPsig: diag.suctionPsig,
                            condSatTempC: diag.condSatTempC,
                            liquidPsig: diag.liquidPsig,
                            curveColor: _gasColor(_selectedGas),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThermoCard(
                              title: s.superheatLabel,
                              mainValue:
                                  '${diag.superheatK.toStringAsFixed(1)} K',
                              subValue:
                                  '${s.evapSatTempLabel}: ${diag.evapSatTempC.toStringAsFixed(1)} °C',
                              color: AppColors.iceBlue,
                              valueKey: const Key('txtSuperheatValue'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildThermoCard(
                              title: s.subcoolingLabel,
                              mainValue:
                                  '${diag.subcoolingK.toStringAsFixed(1)} K',
                              subValue:
                                  '${s.condSatTempLabel}: ${diag.condSatTempC.toStringAsFixed(1)} °C',
                              color: AppColors.caution,
                              valueKey: const Key('txtSubcoolingValue'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Diagnostic Verdict Banner
                Container(
                  key: const Key('cardPtVerdict'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: verdictColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: verdictColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            diag.verdict == ChargeVerdict.optimal
                                ? Icons.verified_rounded
                                : Icons.warning_amber_rounded,
                            color: verdictColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              verdictTitle,
                              key: const Key('txtPtVerdictTitle'),
                              style: TextStyle(
                                color: verdictColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        verdictDesc,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Manifold Pressure & Temperature Inputs
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('inputSuctionPsig'),
                              controller: _suctionPsigCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: s.suctionGaugeLabel,
                                prefixIcon: const Icon(
                                  Icons.ac_unit_rounded,
                                  color: AppColors.iceBlue,
                                  size: 18,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              key: const Key('inputSuctionTemp'),
                              controller: _suctionTempCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: s.suctionLineTempLabel,
                                prefixIcon: const Icon(
                                  Icons.thermostat_rounded,
                                  color: AppColors.iceBlue,
                                  size: 18,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('inputLiquidPsig'),
                              controller: _liquidPsigCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: s.liquidGaugeLabel,
                                prefixIcon: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.caution,
                                  size: 18,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              key: const Key('inputLiquidTemp'),
                              controller: _liquidTempCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: s.liquidLineTempLabel,
                                prefixIcon: const Icon(
                                  Icons.thermostat_rounded,
                                  color: AppColors.caution,
                                  size: 18,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThermoCard({
    required String title,
    required String mainValue,
    required String subValue,
    required Color color,
    required Key valueKey,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mainValue,
            key: valueKey,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
