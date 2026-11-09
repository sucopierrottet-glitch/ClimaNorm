import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../calculators/hvac_calculator.dart';
import '../l10n/app_strings.dart';

class TechnicianProfile {
  final String technicianName;
  final String companyName;
  final String licenseNumber;
  final String email;
  final String phone;
  final String? defaultSignatureBase64;

  const TechnicianProfile({
    this.technicianName = '',
    this.companyName = '',
    this.licenseNumber = '',
    this.email = '',
    this.phone = '',
    this.defaultSignatureBase64,
  });

  Uint8List? get defaultSignatureBytes {
    if (defaultSignatureBase64 == null || defaultSignatureBase64!.isEmpty) {
      return null;
    }
    try {
      return base64Decode(defaultSignatureBase64!);
    } catch (_) {
      return null;
    }
  }

  TechnicianProfile copyWith({
    String? technicianName,
    String? companyName,
    String? licenseNumber,
    String? email,
    String? phone,
    String? defaultSignatureBase64,
    bool clearDefaultSignature = false,
  }) {
    return TechnicianProfile(
      technicianName: technicianName ?? this.technicianName,
      companyName: companyName ?? this.companyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      defaultSignatureBase64: clearDefaultSignature
          ? null
          : (defaultSignatureBase64 ?? this.defaultSignatureBase64),
    );
  }

  Map<String, dynamic> toJson() => {
        'technicianName': technicianName,
        'companyName': companyName,
        'licenseNumber': licenseNumber,
        'email': email,
        'phone': phone,
        'defaultSignatureBase64': defaultSignatureBase64,
      };

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) {
    return TechnicianProfile(
      technicianName: json['technicianName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      defaultSignatureBase64: json['defaultSignatureBase64'] as String?,
    );
  }
}

class SavedHvacProject {
  final String id;
  final String title;
  final String clientName;
  final String siteAddress;
  final String notes;
  final DateTime timestamp;
  final ThermalLoadInput thermalInput;
  final ThermalLoadResult thermalResult;
  final PtDiagnosticResult ptDiagnostic;

  const SavedHvacProject({
    required this.id,
    required this.title,
    this.clientName = '',
    this.siteAddress = '',
    this.notes = '',
    required this.timestamp,
    required this.thermalInput,
    required this.thermalResult,
    required this.ptDiagnostic,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'clientName': clientName,
        'siteAddress': siteAddress,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
        'thermalInput': thermalInput.toJson(),
        'thermalResult': thermalResult.toJson(),
        'ptDiagnostic': ptDiagnostic.toJson(),
      };

  factory SavedHvacProject.fromJson(Map<String, dynamic> json) {
    final tInput = json['thermalInput'] is Map<String, dynamic>
        ? ThermalLoadInput.fromJson(
            json['thermalInput'] as Map<String, dynamic>)
        : const ThermalLoadInput();
    final tResult = json['thermalResult'] is Map<String, dynamic>
        ? ThermalLoadResult.fromJson(
            json['thermalResult'] as Map<String, dynamic>)
        : HvacCalculator.calculateThermalLoad(tInput);
    final ptDiag = json['ptDiagnostic'] is Map<String, dynamic>
        ? PtDiagnosticResult.fromJson(
            json['ptDiagnostic'] as Map<String, dynamic>)
        : HvacCalculator.evaluatePtDiagnostics(
            refrigerant: RefrigerantType.r410a,
            suctionPsig: 118.0,
            liquidPsig: 382.0,
            suctionLineTempC: 12.0,
            liquidLineTempC: 39.0,
          );

    return SavedHvacProject(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? 'Sala Principal HVAC',
      clientName: json['clientName'] as String? ?? '',
      siteAddress: json['siteAddress'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now())
          : DateTime.now(),
      thermalInput: tInput,
      thermalResult: tResult,
      ptDiagnostic: ptDiag,
    );
  }
}

class StorageService extends ChangeNotifier {
  static StorageService instance = StorageService();

  static const String _keyProjects = 'climanorm_saved_projects';
  static const String _keyProfile = 'climanorm_technician_profile';
  static const String _keyLocale = 'climanorm_locale_code';

  final SharedPreferences? _injectedPrefs;
  String _localeCode = 'es';
  bool _initialized = false;

  StorageService([this._injectedPrefs]);

  static bool get isTestEnvironment {
    try {
      final bindingName = WidgetsBinding.instance.runtimeType.toString();
      return bindingName.contains('Test');
    } catch (_) {
      return false;
    }
  }

  static String detectDeviceLocaleCode([ui.Locale? localeOverride]) {
    try {
      final locale = localeOverride ?? ui.PlatformDispatcher.instance.locale;
      final lang = locale.languageCode.toLowerCase();
      if (lang.startsWith('en')) return 'en';
      if (lang.startsWith('pt')) return 'pt';
      return 'es';
    } catch (_) {
      return 'es';
    }
  }

  String get localeCode => _localeCode;
  AppStrings get strings => AppStrings.get(_localeCode);

  /// Camino 1 Paid App: 100% Pro Unlocked permanently
  bool get isProUnlocked => true;

  Future<SharedPreferences> _getPrefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  Future<void> init({ui.Locale? deviceLocaleOverride}) async {
    final prefs = await _getPrefs();
    final saved = prefs.getString(_keyLocale);
    if (saved != null && saved.isNotEmpty) {
      _localeCode = saved;
    } else if (!isTestEnvironment) {
      _localeCode = detectDeviceLocaleCode(deviceLocaleOverride);
    } else {
      _localeCode = 'es';
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_localeCode == code && _initialized) return;
    _localeCode = code;
    _initialized = true;
    final prefs = await _getPrefs();
    await prefs.setString(_keyLocale, code);
    notifyListeners();
  }

  Future<List<SavedHvacProject>> getSavedProjects() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keyProjects);
      if (jsonStr == null || jsonStr.trim().isEmpty) return [];
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      final list = <SavedHvacProject>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(SavedHvacProject.fromJson(item));
          } catch (_) {}
        }
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProject(SavedHvacProject project) async {
    final all = await getSavedProjects();
    final idx = all.indexWhere((e) => e.id == project.id);
    if (idx >= 0) {
      all[idx] = project;
    } else {
      all.insert(0, project);
    }
    final prefs = await _getPrefs();
    await prefs.setString(
      _keyProjects,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    final all = await getSavedProjects();
    all.removeWhere((e) => e.id == id);
    final prefs = await _getPrefs();
    await prefs.setString(
      _keyProjects,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<TechnicianProfile> getProfile() async {
    try {
      final prefs = await _getPrefs();
      final str = prefs.getString(_keyProfile);
      if (str == null || str.trim().isEmpty) {
        return const TechnicianProfile();
      }
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return TechnicianProfile.fromJson(decoded);
      }
      return const TechnicianProfile();
    } catch (_) {
      return const TechnicianProfile();
    }
  }

  Future<void> saveProfile(TechnicianProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyProjects);
    await prefs.remove(_keyProfile);
    await prefs.remove(_keyLocale);
    _localeCode = 'es';
    notifyListeners();
  }
}
