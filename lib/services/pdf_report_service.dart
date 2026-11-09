import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../calculators/hvac_calculator.dart';
import 'storage_service.dart';

class PdfReportService {
  static Future<Uint8List> generateProjectReport({
    required SavedHvacProject project,
    required TechnicianProfile profile,
    Uint8List? signatureBytes,
  }) async {
    final doc = pw.Document(
      title: 'ClimaNorm Pro - Memoria Técnica HVAC (${project.title})',
      author: profile.technicianName.isNotEmpty
          ? profile.technicianName
          : 'ClimaNorm Pro Engine',
    );

    final effectiveSig = signatureBytes ?? profile.defaultSignatureBytes;
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(project.timestamp);
    final refSpec = HvacCalculator.getSpec(project.ptDiagnostic.refrigerant);

    final verdictText = switch (project.ptDiagnostic.verdict) {
      ChargeVerdict.undercharged => 'SUBCARGADO / UNDERCHARGED',
      ChargeVerdict.optimal => 'ÓPTIMO / OPTIMAL (CUMPLE ASHRAE)',
      ChargeVerdict.overcharged => 'SOBRECARGADO / OVERCHARGED',
    };

    final verdictColor = switch (project.ptDiagnostic.verdict) {
      ChargeVerdict.undercharged => PdfColors.amber800,
      ChargeVerdict.optimal => PdfColors.green700,
      ChargeVerdict.overcharged => PdfColors.red700,
    };

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#0B0F19'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CLIMANORM PRO - MEMORIA TECNICA HVAC&R',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#38BDF8'),
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Cálculo de Carga Térmica BTU/h, P-T & Diagnóstico Recalentamiento / Subenfriamiento',
                      style: const pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'ASHRAE / ISO 5151 / RITE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#00E676'),
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(
                        color: PdfColors.grey400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Project & Client Information
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PROYECTO: ${project.title}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Cliente: ${project.clientName.isEmpty ? "General" : project.clientName}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Ubicación: ${project.siteAddress.isEmpty ? "En Obra" : project.siteAddress}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Responsable: ${profile.technicianName.isEmpty ? "Ingeniero HVAC" : profile.technicianName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Empresa: ${profile.companyName.isEmpty ? "SimpleAppsPG Engineering" : profile.companyName}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Matrícula / Cert.: ${profile.licenseNumber.isEmpty ? "EPA-608 / RITE" : profile.licenseNumber}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // Section 1: Thermal Load Calculation
          pw.Text(
            '1. DIMENSIONAMIENTO DE CARGA TÉRMICA (BTU/h & TONELAJE)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Parámetro de Diseño', 'Valor Ingresado', 'Aporte Térmico'],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#161F30'),
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            data: [
              [
                'Área del Recinto y Altura',
                '${project.thermalInput.areaM2.toStringAsFixed(1)} m² (${project.thermalInput.areaFt2.toStringAsFixed(0)} ft²) × ${project.thermalInput.ceilingHeightMeters.toStringAsFixed(1)} m',
                '${project.thermalResult.envelopeBtu.toStringAsFixed(0)} BTU/h',
              ],
              [
                'Ocupantes en Sala',
                '${project.thermalInput.occupants} personas',
                '${project.thermalResult.occupantsBtu.toStringAsFixed(0)} BTU/h',
              ],
              [
                'Equipos e Iluminación Interna',
                '${project.thermalInput.appliancesWatts.toStringAsFixed(0)} W',
                '${project.thermalResult.appliancesBtu.toStringAsFixed(0)} BTU/h',
              ],
              [
                'CARGA TÉRMICA TOTAL REQUERIDA',
                '${project.thermalResult.frigoriasPerHour.toStringAsFixed(0)} Frig/h  |  ${project.thermalResult.thermalKw.toStringAsFixed(2)} kW',
                '${project.thermalResult.totalBtuPerHour.toStringAsFixed(0)} BTU/h',
              ],
              [
                'EQUIPO COMERCIAL RECOMENDADO',
                'Capacidad Nominal: ${project.thermalResult.recommendedNominalBtu} BTU/h',
                '${project.thermalResult.recommendedTons.toStringAsFixed(1)} Toneladas (TR)',
              ],
            ],
          ),
          pw.SizedBox(height: 18),

          // Section 2: Refrigerant P-T & Superheat/Subcooling Diagnostics
          pw.Text(
            '2. DIAGNÓSTICO TERMODINÁMICO P-T Y CARGA DE REFRIGERANTE (${refSpec.code})',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Línea / Parámetro', 'Presión Manométrica', 'Temp. Saturación', 'Temp. Medida / Delta'],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#161F30'),
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            data: [
              [
                'Gas Refrigerante Seleccionado',
                refSpec.code,
                'Clase ${refSpec.safetyClass}',
                'GWP: ${refSpec.gwp}',
              ],
              [
                'Succión / Baja (Evaporador)',
                '${project.ptDiagnostic.suctionPsig.toStringAsFixed(1)} PSIG',
                '${project.ptDiagnostic.evapSatTempC.toStringAsFixed(1)} °C',
                'Tubo: ${project.ptDiagnostic.suctionLineTempC.toStringAsFixed(1)} °C (SH: ${project.ptDiagnostic.superheatK.toStringAsFixed(1)} K)',
              ],
              [
                'Líquido / Alta (Condensador)',
                '${project.ptDiagnostic.liquidPsig.toStringAsFixed(1)} PSIG',
                '${project.ptDiagnostic.condSatTempC.toStringAsFixed(1)} °C',
                'Tubo: ${project.ptDiagnostic.liquidLineTempC.toStringAsFixed(1)} °C (SC: ${project.ptDiagnostic.subcoolingK.toStringAsFixed(1)} K)',
              ],
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: verdictColor, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'VEREDICTO DE DIAGNÓSTICO DE CARGA:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Text(
                  verdictText,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: verdictColor,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Section 3: Signature Block
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (effectiveSig != null && effectiveSig.isNotEmpty)
                    pw.Container(
                      height: 60,
                      width: 180,
                      child: pw.Image(
                        pw.MemoryImage(effectiveSig),
                        fit: pw.BoxFit.contain,
                      ),
                    )
                  else
                    pw.SizedBox(height: 50, width: 180),
                  pw.Container(
                    width: 200,
                    height: 1,
                    color: PdfColors.grey800,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.technicianName.isEmpty
                        ? 'Firma del Ingeniero / Técnico HVAC'
                        : profile.technicianName,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Certificación: ${profile.licenseNumber.isEmpty ? "EPA-608 / RITE" : profile.licenseNumber}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'Generado por ClimaNorm Pro v1.0.0\nSimpleAppsPG Offline Precision Engine',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }
}
