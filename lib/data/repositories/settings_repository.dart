// =============================================================================
// مستودع الإعدادات - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// مستودع لحفظ وقراءة إعدادات التطبيق باستخدام SharedPreferences
class SettingsRepository {
  SettingsRepository._();

  static final SettingsRepository _instance = SettingsRepository._();
  static SettingsRepository get instance => _instance;

  static const String _settingsKey = 'app_settings_v2';
  static const String _firstRunKey = 'first_run_completed';
  static const String _themeOverrideKey = 'theme_mode_override';

  SharedPreferences? _prefs;

  /// تهيئة المستودع
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateIfNeeded();
  }

  SharedPreferences get _safePrefs {
    final prefs = _prefs;
    if (prefs == null) throw StateError('SettingsRepository not initialized');
    return prefs;
  }

  /// هل هذه أول مرة يتم تشغيل التطبيق؟
  bool get isFirstRun => _safePrefs.getBool(_firstRunKey) != true;

  /// تعليم التشغيل الأول كمنتهٍ
  Future<void> markFirstRunCompleted() async {
    await _safePrefs.setBool(_firstRunKey, true);
  }

  /// قراءة الإعدادات الحالية
  AppSettings loadSettings() {
    final jsonStr = _safePrefs.getString(_settingsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return AppSettings.defaultSettings();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (e) {
      // في حالة الخطأ، استخدم الإعدادات الافتراضية
      return AppSettings.defaultSettings();
    }
  }

  /// حفظ الإعدادات
  Future<void> saveSettings(AppSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _safePrefs.setString(_settingsKey, jsonStr);
    // حفظ وضع الثيم بشكل منفصل لسرعة الوصول
    await _safePrefs.setString(_themeOverrideKey, settings.themeMode);
  }

  /// قراءة وضع الثيم بسرعة (بدون تحميل كل الإعدادات)
  String getThemeMode() {
    return _safePrefs.getString(_themeOverrideKey) ?? 'system';
  }

  /// تحديث حقل معين فقط
  Future<AppSettings> updateField(
    AppSettings current,
    AppSettings Function(AppSettings) updater,
  ) async {
    final updated = updater(current);
    await saveSettings(updated);
    return updated;
  }

  /// إعادة تعيين جميع الإعدادات إلى القيم الافتراضية
  Future<AppSettings> resetToDefaults() async {
    final defaults = AppSettings.defaultSettings();
    await saveSettings(defaults);
    return defaults;
  }

  /// تصدير الإعدادات كـ JSON
  String exportSettingsJson(AppSettings settings) {
    return const JsonEncoder.withIndent('  ').convert(settings.toMap());
  }

  /// استيراد الإعدادات من JSON
  Future<AppSettings?> importSettingsFromJson(String jsonStr) async {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final settings = AppSettings.fromMap(map);
      await saveSettings(settings);
      return settings;
    } catch (e) {
      return null;
    }
  }

  /// ترقية الإعدادات القديمة إذا لزم الأمر
  Future<void> _migrateIfNeeded() async {
    // يمكن إضافة منطق ترحيل الإعدادات هنا مستقبلاً
  }

  /// تسجيل تاريخ النسخ الاحتياطي
  Future<AppSettings> recordBackup(AppSettings settings) async {
    final updated = settings.copyWith(lastBackupDate: DateTime.now());
    await saveSettings(updated);
    return updated;
  }

  /// البحث عن مسار النسخ الاحتياطي الافتراضي
  String getDefaultBackupPath() {
    // يمكن الاستفادة من path_provider هنا
    return '';
  }
}
