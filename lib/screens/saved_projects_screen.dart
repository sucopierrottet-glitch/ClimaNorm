import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../services/pdf_report_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/signature_dialog.dart';

class SavedProjectsScreen extends StatefulWidget {
  final ValueChanged<SavedHvacProject>? onSelectProject;

  const SavedProjectsScreen({super.key, this.onSelectProject});

  @override
  State<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  List<SavedHvacProject> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    StorageService.instance.addListener(_load);
  }

  @override
  void dispose() {
    StorageService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final items = await StorageService.instance.getSavedProjects();
    if (!mounted) return;
    setState(() {
      _projects = items;
      _loading = false;
    });
  }

  Future<void> _signAndExportProjectPdf(SavedHvacProject project) async {
    final profile = await StorageService.instance.getProfile();
    if (!mounted) return;

    final sigRes = await SignatureDialog.show(
      context,
      technicianName: profile.technicianName,
      licenseNumber: profile.licenseNumber,
    );
    if (sigRes == null || !mounted) return;

    final pdfBytes = await PdfReportService.generateProjectReport(
      project: project,
      profile: profile.copyWith(
        technicianName: sigRes.technicianName,
        licenseNumber: sigRes.licenseNumber,
      ),
      signatureBytes: sigRes.signatureBytes,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'ClimaNorm_${project.title.replaceAll(" ", "_")}.pdf',
    );
  }

  Future<void> _deleteProject(String id) async {
    await StorageService.instance.deleteProject(id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(
                  Icons.folder_copy_rounded,
                  color: AppColors.iceBlue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(s.savedProjectsTitle),
              ],
            ),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.iceBlue),
                )
              : _projects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.folder_open_rounded,
                              size: 56,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              s.noSavedProjects,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _projects.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = _projects[index];
                        final dateStr = DateFormat('yyyy-MM-dd HH:mm')
                            .format(p.timestamp);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.compliant.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.compliant,
                                      ),
                                    ),
                                    child: Text(
                                      '${p.thermalResult.recommendedTons.toStringAsFixed(1)} T',
                                      style: const TextStyle(
                                        color: AppColors.compliant,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.clientName.isEmpty ? "HVAC" : p.clientName} • $dateStr',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${p.thermalResult.totalBtuPerHour.toStringAsFixed(0)} BTU/h  |  ${p.thermalResult.frigoriasPerHour.toStringAsFixed(0)} fg/h  |  ${p.thermalResult.thermalKw.toStringAsFixed(2)} kW',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.iceBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        widget.onSelectProject?.call(p),
                                    icon: const Icon(
                                      Icons.upload_rounded,
                                      size: 16,
                                      color: AppColors.iceBlue,
                                    ),
                                    label: Text(
                                      s.loadProjectBtn,
                                      style: const TextStyle(
                                        color: AppColors.iceBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _signAndExportProjectPdf(p),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.compliant,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      s.signAndExportPdf,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteProject(p.id),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.critical,
                                      size: 20,
                                    ),
                                    tooltip: s.deleteProjectBtn,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
