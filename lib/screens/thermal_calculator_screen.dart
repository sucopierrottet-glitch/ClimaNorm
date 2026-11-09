import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../calculators/hvac_calculator.dart';
import '../services/pdf_report_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/btu_gauge_painter.dart';
import '../widgets/signature_dialog.dart';

class ThermalCalculatorScreen extends StatefulWidget {
  final VoidCallback? onProjectSaved;

  const ThermalCalculatorScreen({super.key, this.onProjectSaved});

  @override
  State<ThermalCalculatorScreen> createState() =>
      ThermalCalculatorScreenState();
}

class ThermalCalculatorScreenState extends State<ThermalCalculatorScreen> {
  final _areaController = TextEditingController(text: '28');
  final _heightController = TextEditingController(text: '2.6');
  final _occupantsController = TextEditingController(text: '3');
  final _wattsController = TextEditingController(text: '450');

  AreaUnit _areaUnit = AreaUnit.m2;
  ClimateZone _climateZone = ClimateZone.hot;
  SunExposure _sunExposure = SunExposure.moderate;

  @override
  void dispose() {
    _areaController.dispose();
    _heightController.dispose();
    _occupantsController.dispose();
    _wattsController.dispose();
    super.dispose();
  }

  ThermalLoadInput get currentInput {
    final area = double.tryParse(_areaController.text.trim()) ?? 28.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 2.6;
    final occupants = int.tryParse(_occupantsController.text.trim()) ?? 3;
    final watts = double.tryParse(_wattsController.text.trim()) ?? 450.0;

    return ThermalLoadInput(
      area: area,
      areaUnit: _areaUnit,
      ceilingHeightMeters: height,
      climateZone: _climateZone,
      sunExposure: _sunExposure,
      occupants: occupants,
      appliancesWatts: watts,
    );
  }

  void loadProject(SavedHvacProject project) {
    final inp = project.thermalInput;
    setState(() {
      _areaController.text = inp.area.toStringAsFixed(1);
      _heightController.text = inp.ceilingHeightMeters.toStringAsFixed(1);
      _occupantsController.text = inp.occupants.toString();
      _wattsController.text = inp.appliancesWatts.toStringAsFixed(0);
      _areaUnit = inp.areaUnit;
      _climateZone = inp.climateZone;
      _sunExposure = inp.sunExposure;
    });
  }

  Future<void> _saveCurrentProject() async {
    final s = StorageService.instance.strings;
    final titleCtrl = TextEditingController(
      text: 'Sala HVAC ${currentInput.areaM2.toStringAsFixed(0)} m²',
    );
    final clientCtrl = TextEditingController(text: 'Cliente Comercial');
    final siteCtrl = TextEditingController(text: 'Planta Baja');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          s.saveProjectBtn,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('inputSaveProjectTitle'),
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: s.projectTitleLabel),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: clientCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: s.clientNameLabel),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: siteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: s.siteAddressLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            key: const Key('btnConfirmSaveProject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.compliant,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              s.save,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final input = currentInput;
    final res = HvacCalculator.calculateThermalLoad(input);
    final ptDiag = HvacCalculator.evaluatePtDiagnostics(
      refrigerant: RefrigerantType.r410a,
      suctionPsig: 118.0,
      liquidPsig: 382.0,
      suctionLineTempC: 12.0,
      liquidLineTempC: 39.0,
    );

    final project = SavedHvacProject(
      id: const Uuid().v4(),
      title: titleCtrl.text.trim().isEmpty
          ? 'Proyecto HVAC'
          : titleCtrl.text.trim(),
      clientName: clientCtrl.text.trim(),
      siteAddress: siteCtrl.text.trim(),
      timestamp: DateTime.now(),
      thermalInput: input,
      thermalResult: res,
      ptDiagnostic: ptDiag,
    );

    await StorageService.instance.saveProject(project);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${project.title} — Guardado'),
        backgroundColor: AppColors.compliant,
      ),
    );
    widget.onProjectSaved?.call();
  }

  Future<void> _exportSignedPdf() async {
    final profile = await StorageService.instance.getProfile();
    if (!mounted) return;

    final sigRes = await SignatureDialog.show(
      context,
      technicianName: profile.technicianName,
      licenseNumber: profile.licenseNumber,
    );
    if (sigRes == null || !mounted) return;

    final input = currentInput;
    final res = HvacCalculator.calculateThermalLoad(input);
    final ptDiag = HvacCalculator.evaluatePtDiagnostics(
      refrigerant: RefrigerantType.r410a,
      suctionPsig: 118.0,
      liquidPsig: 382.0,
      suctionLineTempC: 12.0,
      liquidLineTempC: 39.0,
    );

    final tempProject = SavedHvacProject(
      id: const Uuid().v4(),
      title: 'Cálculo BTU/h (${input.areaM2.toStringAsFixed(0)} m²)',
      clientName: 'Reporte Técnico en Campo',
      siteAddress: 'Obra HVAC',
      timestamp: DateTime.now(),
      thermalInput: input,
      thermalResult: res,
      ptDiagnostic: ptDiag,
    );

    final pdfBytes = await PdfReportService.generateProjectReport(
      project: tempProject,
      profile: profile.copyWith(
        technicianName: sigRes.technicianName,
        licenseNumber: sigRes.licenseNumber,
      ),
      signatureBytes: sigRes.signatureBytes,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'ClimaNorm_Memoria_HVAC.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;
        final input = currentInput;
        final result = HvacCalculator.calculateThermalLoad(input);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(
                  Icons.ac_unit_rounded,
                  color: AppColors.iceBlue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.thermalTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('btnSaveThermalAppBar'),
                tooltip: s.saveProjectBtn,
                icon: const Icon(
                  Icons.bookmark_add_outlined,
                  color: AppColors.compliant,
                ),
                onPressed: _saveCurrentProject,
              ),
              IconButton(
                key: const Key('btnExportPdfAppBar'),
                tooltip: s.exportPdfBtn,
                icon: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.iceBlue,
                ),
                onPressed: _exportSignedPdf,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Visual BTU/h & Tonnage Gauge Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.iceBlue.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.totalThermalLoadLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.iceBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 155,
                        width: double.infinity,
                        child: CustomPaint(
                          key: const Key('btuGaugeCustomPaint'),
                          painter: BtuGaugePainter(
                            totalBtuPerHour: result.totalBtuPerHour,
                            recommendedTons: result.recommendedTons,
                            utilizationPercent:
                                result.capacityUtilizationPercent,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${result.totalBtuPerHour.toStringAsFixed(0)} BTU/h',
                                    key: const Key('txtTotalBtuResult'),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${s.recommendedTonnageLabel}: ${result.recommendedTons.toStringAsFixed(1)} T (${result.recommendedNominalBtu} BTU/h)',
                                    key: const Key('txtRecommendedTonnage'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.compliant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricMiniBox(
                              label: s.frigoriasLabel,
                              value:
                                  '${result.frigoriasPerHour.toStringAsFixed(0)} fg/h',
                              color: AppColors.iceBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricMiniBox(
                              label: s.thermalKwLabel,
                              value:
                                  '${result.thermalKw.toStringAsFixed(2)} kW',
                              color: AppColors.compliant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricMiniBox(
                              label: 'Tonelaje Exacto',
                              value:
                                  '${result.exactTons.toStringAsFixed(2)} TR',
                              color: AppColors.caution,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Room Dimensions & Climate Zone Card
                Text(
                  s.roomDimensionsSection,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              key: const Key('inputRoomArea'),
                              controller: _areaController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText:
                                    '${s.areaLabel} (${_areaUnit == AreaUnit.m2 ? "m²" : "ft²"})',
                                prefixIcon: const Icon(
                                  Icons.square_foot_rounded,
                                  color: AppColors.iceBlue,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SegmentedButton<AreaUnit>(
                            segments: const [
                              ButtonSegment(
                                value: AreaUnit.m2,
                                label: Text('m²'),
                              ),
                              ButtonSegment(
                                value: AreaUnit.ft2,
                                label: Text('ft²'),
                              ),
                            ],
                            selected: {_areaUnit},
                            onSelectionChanged: (vals) {
                              setState(() => _areaUnit = vals.first);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputCeilingHeight'),
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.ceilingHeightLabel,
                          prefixIcon: const Icon(
                            Icons.height_rounded,
                            color: AppColors.iceBlue,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.climateZoneLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip<ClimateZone>(
                            key: const Key('chipClimate_cold'),
                            label: s.climateCold,
                            value: ClimateZone.cold,
                            groupValue: _climateZone,
                            onSelected: (v) => setState(() => _climateZone = v),
                          ),
                          _buildChoiceChip<ClimateZone>(
                            key: const Key('chipClimate_temperate'),
                            label: s.climateTemperate,
                            value: ClimateZone.temperate,
                            groupValue: _climateZone,
                            onSelected: (v) => setState(() => _climateZone = v),
                          ),
                          _buildChoiceChip<ClimateZone>(
                            key: const Key('chipClimate_hot'),
                            label: s.climateHot,
                            value: ClimateZone.hot,
                            groupValue: _climateZone,
                            onSelected: (v) => setState(() => _climateZone = v),
                          ),
                          _buildChoiceChip<ClimateZone>(
                            key: const Key('chipClimate_tropical'),
                            label: s.climateTropical,
                            value: ClimateZone.tropical,
                            groupValue: _climateZone,
                            onSelected: (v) => setState(() => _climateZone = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.sunExposureLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip<SunExposure>(
                            key: const Key('chipSun_low'),
                            label: s.sunLow,
                            value: SunExposure.low,
                            groupValue: _sunExposure,
                            onSelected: (v) => setState(() => _sunExposure = v),
                          ),
                          _buildChoiceChip<SunExposure>(
                            key: const Key('chipSun_moderate'),
                            label: s.sunModerate,
                            value: SunExposure.moderate,
                            groupValue: _sunExposure,
                            onSelected: (v) => setState(() => _sunExposure = v),
                          ),
                          _buildChoiceChip<SunExposure>(
                            key: const Key('chipSun_high'),
                            label: s.sunHigh,
                            value: SunExposure.high,
                            groupValue: _sunExposure,
                            onSelected: (v) => setState(() => _sunExposure = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Internal Loads (Occupants & Appliances Watts)
                Text(
                  s.internalLoadsSection,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('inputOccupants'),
                          controller: _occupantsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: s.occupantsLabel,
                            prefixIcon: const Icon(
                              Icons.people_alt_outlined,
                              color: AppColors.compliant,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('inputAppliancesWatts'),
                          controller: _wattsController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: s.appliancesWattsLabel,
                            prefixIcon: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.caution,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('btnSaveProjectThermal'),
                        onPressed: _saveCurrentProject,
                        icon: const Icon(
                          Icons.bookmark_add_rounded,
                          color: AppColors.compliant,
                        ),
                        label: Text(
                          s.saveProjectBtn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                          backgroundColor: AppColors.surfaceCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        key: const Key('btnExportPdfThermal'),
                        onPressed: _exportSignedPdf,
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.black,
                        ),
                        label: Text(
                          s.exportPdfBtn,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iceBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricMiniBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip<T>({
    required Key key,
    required String label,
    required T value,
    required T groupValue,
    required ValueChanged<T> onSelected,
  }) {
    final selected = value == groupValue;
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.iceBlue.withValues(alpha: 0.25),
      backgroundColor: AppColors.surfaceElevated,
      labelStyle: TextStyle(
        color: selected ? AppColors.iceBlue : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? AppColors.iceBlue : AppColors.borderSubtle,
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}
