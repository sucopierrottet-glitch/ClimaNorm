import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../theme/app_theme.dart';

class SignatureDialogResult {
  final Uint8List signatureBytes;
  final String technicianName;
  final String licenseNumber;

  const SignatureDialogResult({
    required this.signatureBytes,
    required this.technicianName,
    required this.licenseNumber,
  });
}

class SignatureDialog extends StatefulWidget {
  final String initialName;
  final String initialLicense;

  const SignatureDialog({
    super.key,
    this.initialName = 'Ing. Carlos Mendoza',
    this.initialLicense = 'HVAC-EPA-608',
  });

  static Future<SignatureDialogResult?> show(
    BuildContext context, {
    String? technicianName,
    String? licenseNumber,
  }) {
    return showDialog<SignatureDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SignatureDialog(
        initialName: (technicianName != null && technicianName.isNotEmpty)
            ? technicianName
            : 'Ing. Carlos Mendoza',
        initialLicense: (licenseNumber != null && licenseNumber.isNotEmpty)
            ? licenseNumber
            : 'HVAC-EPA-608',
      ),
    );
  }

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  late final SignatureController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _licenseController;

  bool _isExporting = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3.0,
      penColor: const Color(0xFF0F172A),
      exportBackgroundColor: Colors.white,
      onDrawEnd: () {
        if (_validationError != null) {
          setState(() => _validationError = null);
        }
      },
    );
    _nameController = TextEditingController(text: widget.initialName);
    _licenseController = TextEditingController(text: widget.initialLicense);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_controller.isEmpty) {
      setState(() {
        _validationError =
            'Por favor dibuje su firma en el recuadro / Please sign above.';
      });
      return;
    }

    setState(() => _isExporting = true);
    try {
      final pngBytes = await _controller.toPngBytes();
      if (!mounted) return;
      if (pngBytes == null || pngBytes.isEmpty) {
        setState(() {
          _isExporting = false;
          _validationError = 'Error al exportar firma.';
        });
        return;
      }

      Navigator.of(context).pop(
        SignatureDialogResult(
          signatureBytes: pngBytes,
          technicianName: _nameController.text.trim().isEmpty
              ? 'HVAC Engineer'
              : _nameController.text.trim(),
          licenseNumber: _licenseController.text.trim().isEmpty
              ? 'EPA-608 / RITE'
              : _licenseController.text.trim(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _validationError = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.iceBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.draw_rounded,
                      color: AppColors.iceBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Firma Técnica Digital HVAC',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Ingeniero / Técnico Responsable',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _licenseController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Matrícula / Certificación EPA / RITE',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Panel de Firma Táctil',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _controller.clear(),
                    icon: const Icon(Icons.refresh, size: 16, color: AppColors.caution),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(color: AppColors.caution, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _validationError != null
                          ? AppColors.critical
                          : AppColors.iceBlue,
                      width: 1.5,
                    ),
                  ),
                  child: Signature(
                    controller: _controller,
                    height: 160,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationError!,
                  style: const TextStyle(color: AppColors.critical, fontSize: 12),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.compliant,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: _isExporting ? null : _handleConfirm,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Confirmar Firma',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
