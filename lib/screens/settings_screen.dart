import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/signature_dialog.dart';
import 'welcome_landing_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _defaultSigBase64;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _licenseCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.instance.getProfile();
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = profile.technicianName;
      _companyCtrl.text = profile.companyName;
      _licenseCtrl.text = profile.licenseNumber;
      _phoneCtrl.text = profile.phone;
      _emailCtrl.text = profile.email;
      _defaultSigBase64 = profile.defaultSignatureBase64;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final profile = TechnicianProfile(
      technicianName: _nameCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      defaultSignatureBase64: _defaultSigBase64,
    );
    await StorageService.instance.saveProfile(profile);
    if (!mounted) return;
    final s = StorageService.instance.strings;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.settingsSavedSuccess),
        backgroundColor: AppColors.compliant,
      ),
    );
  }

  Future<void> _captureDefaultSignature() async {
    final res = await SignatureDialog.show(
      context,
      technicianName: _nameCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
    );
    if (res != null && mounted) {
      setState(() {
        _defaultSigBase64 = base64Encode(res.signatureBytes);
        if (_nameCtrl.text.trim().isEmpty) {
          _nameCtrl.text = res.technicianName;
        }
        if (_licenseCtrl.text.trim().isEmpty) {
          _licenseCtrl.text = res.licenseNumber;
        }
      });
      await _saveProfile();
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://sucopierrottet-glitch.github.io/climanorm-privacy/',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;
        final currentLang = StorageService.instance.localeCode;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(s.settingsTitle),
            actions: [
              IconButton(
                key: const Key('btnSaveSettingsAppBar'),
                icon: const Icon(
                  Icons.check_rounded,
                  color: AppColors.compliant,
                ),
                tooltip: s.save,
                onPressed: _saveProfile,
              ),
            ],
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.iceBlue),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. 1-Tap Language Switcher (ES / EN / PT)
                      _buildSectionTitle(s.languageHeader),
                      const SizedBox(height: 8),
                      Material(
                        color: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _buildLanguageTile(
                              code: 'es',
                              flag: '🇪🇸',
                              label: 'Español',
                              currentLang: currentLang,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            _buildLanguageTile(
                              code: 'en',
                              flag: '🇺🇸',
                              label: 'English',
                              currentLang: currentLang,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            _buildLanguageTile(
                              code: 'pt',
                              flag: '🇧🇷',
                              label: 'Português',
                              currentLang: currentLang,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Camino 1 Paid App — 100% Pro Unlocked Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0369A1), Color(0xFF047857)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.proActiveTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.proActiveSubtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Technician Profile Form
                      _buildSectionTitle(s.technicianProfileHeader),
                      const SizedBox(height: 6),
                      Text(
                        s.technicianProfileDesc,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsTechName'),
                        controller: _nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.technicianNameLabel,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        key: const Key('inputSettingsCompanyName'),
                        controller: _companyCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.companyNameLabel,
                          prefixIcon: const Icon(
                            Icons.business_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        key: const Key('inputSettingsLicense'),
                        controller: _licenseCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.licenseNumberLabel,
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        key: const Key('inputSettingsPhone'),
                        controller: _phoneCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.phoneLabel,
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        key: const Key('inputSettingsEmail'),
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.emailLabel,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Default Digital Signature
                      _buildSectionTitle(s.signatureSectionHeader),
                      const SizedBox(height: 10),
                      if (_defaultSigBase64 != null &&
                          _defaultSigBase64!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.compliant),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.memory(
                                  base64Decode(_defaultSigBase64!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _captureDefaultSignature,
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 16,
                                      color: AppColors.iceBlue,
                                    ),
                                    label: const Text(
                                      'Cambiar Firma',
                                      style: TextStyle(
                                        color: AppColors.iceBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          key: const Key('btnConfigureDefaultSignature'),
                          onPressed: _captureDefaultSignature,
                          icon: const Icon(
                            Icons.draw_rounded,
                            color: AppColors.iceBlue,
                          ),
                          label: Text(
                            s.configureSignatureBtn,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                            backgroundColor: AppColors.surfaceCard,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // 5. Normative Standards
                      _buildSectionTitle(s.technicalStandardsHeader),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.technicalStandardsDesc,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _StandardBadge('ASHRAE Handbook'),
                                _StandardBadge('ISO 5151'),
                                _StandardBadge('RITE / UNE'),
                                _StandardBadge('AHRI 210/240'),
                                _StandardBadge('EPA Section 608'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Privacy Policy & Landing
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        tileColor: AppColors.surfaceCard,
                        onTap: _openPrivacyPolicy,
                        leading: const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColors.iceBlue,
                        ),
                        title: Text(
                          s.privacyPolicyBtn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          s.appVersion,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeLandingScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 18,
                          color: AppColors.iceBlue,
                        ),
                        label: const Text(
                          'Welcome Landing Screen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        key: const Key('btnSaveProfile'),
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          s.saveSettingsBtn,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iceBlue,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _buildLanguageTile({
    required String code,
    required String flag,
    required String label,
    required String currentLang,
  }) {
    final selected = currentLang.startsWith(code);
    return ListTile(
      key: Key('langOption_$code'),
      onTap: () => StorageService.instance.setLocale(code),
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.compliant)
          : const Icon(
              Icons.radio_button_unchecked_rounded,
              color: AppColors.textTertiary,
            ),
    );
  }
}

class _StandardBadge extends StatelessWidget {
  final String text;
  const _StandardBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.iceBlue,
        ),
      ),
    );
  }
}
