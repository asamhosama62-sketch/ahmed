// =============================================================================
// موفرو الإعدادات - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

// ─── Provider للمستودع ────────────────────────────────────────────────────────
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository.instance;
});

// ─── StateNotifier للإعدادات ──────────────────────────────────────────────────
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(_repository.loadSettings());

  final SettingsRepository _repository;

  /// تحديث كامل للإعدادات
  Future<void> updateSettings(AppSettings settings) async {
    await _repository.saveSettings(settings);
    state = settings;
  }

  /// تحديث اسم الشركة
  Future<void> updateCompanyName(String name) async {
    final updated = state.copyWith(companyName: name);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث اسم الفرع
  Future<void> updateBranchName(String branch) async {
    final updated = state.copyWith(branchName: branch);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث بيانات الشركة دفعة واحدة
  Future<void> updateCompanyInfo({
    String? companyName,
    String? companyNameEn,
    String? branchName,
    String? companyPhones,
    String? companyAddress,
    String? companyEmail,
    String? companyWebsite,
    String? companyLicenseNumber,
    String? companyCRNumber,
  }) async {
    final updated = state.copyWith(
      companyName: companyName,
      companyNameEn: companyNameEn,
      branchName: branchName,
      companyPhones: companyPhones,
      companyAddress: companyAddress,
      companyEmail: companyEmail,
      companyWebsite: companyWebsite,
      companyLicenseNumber: companyLicenseNumber,
      companyCRNumber: companyCRNumber,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث بيانات الموظف
  Future<void> updateEmployeeInfo({
    String? name,
    String? employeeId,
    String? signature,
    String? phone,
    String? position,
  }) async {
    final updated = state.copyWith(
      defaultEmployeeName: name,
      defaultEmployeeId: employeeId,
      defaultEmployeeSignature: signature,
      defaultEmployeePhone: phone,
      defaultEmployeePosition: position,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث وضع الثيم
  Future<void> updateThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث اللون الرئيسي
  Future<void> updatePrimaryColor(String colorHex) async {
    final updated = state.copyWith(primaryColorHex: colorHex);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث إعدادات الطباعة
  Future<void> updatePrintSettings({
    String? format,
    int? copies,
    bool? showQrCode,
    bool? showLogo,
    double? paperWidth,
    double? margin,
    double? fontSize,
  }) async {
    final updated = state.copyWith(
      defaultPrintFormat: format,
      printCopies: copies,
      showQrCode: showQrCode,
      showCompanyLogo: showLogo,
      thermalPaperWidth: paperWidth,
      pdfMargin: margin,
      fontSizePdf: fontSize,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث إعدادات الحوالة الافتراضية
  Future<void> updateTransferDefaults({
    String? currency,
    String? agent,
    String? destination,
    double? feePercentage,
    double? minimumFee,
    List<String>? currencies,
    List<String>? destinations,
    List<String>? agents,
  }) async {
    final updated = state.copyWith(
      defaultCurrency: currency,
      defaultAgent: agent,
      defaultDestination: destination,
      defaultFeePercentage: feePercentage,
      minimumFee: minimumFee,
      currencies: currencies,
      destinations: destinations,
      agents: agents,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تحديث إعدادات الأمان
  Future<void> updateSecuritySettings({
    bool? requirePin,
    String? pinCode,
    int? sessionTimeout,
    bool? showAmounts,
  }) async {
    final updated = state.copyWith(
      requirePinToOpen: requirePin,
      pinCode: pinCode,
      sessionTimeoutMinutes: sessionTimeout,
      showAmountsInList: showAmounts,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تبديل الأرقام العربية/الإنجليزية
  Future<void> toggleArabicNumerals() async {
    final updated = state.copyWith(
      useArabicNumerals: !state.useArabicNumerals,
    );
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تبديل المؤثرات الحركية
  Future<void> toggleAnimations() async {
    final updated = state.copyWith(showAnimations: !state.showAnimations);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تبديل الوضع المضغوط
  Future<void> toggleCompactMode() async {
    final updated = state.copyWith(compactMode: !state.compactMode);
    await _repository.saveSettings(updated);
    state = updated;
  }

  /// تسجيل نسخة احتياطية
  Future<void> recordBackup() async {
    final updated = await _repository.recordBackup(state);
    state = updated;
  }

  /// إعادة تعيين الإعدادات
  Future<void> resetToDefaults() async {
    final defaults = await _repository.resetToDefaults();
    state = defaults;
  }

  /// إضافة عملة جديدة
  Future<void> addCurrency(String currency) async {
    if (!state.currencies.contains(currency)) {
      final updated = state.copyWith(
        currencies: [...state.currencies, currency],
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }

  /// حذف عملة
  Future<void> removeCurrency(String currency) async {
    if (state.currencies.length > 1) {
      final updated = state.copyWith(
        currencies: state.currencies.where((c) => c != currency).toList(),
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }

  /// إضافة وجهة جديدة
  Future<void> addDestination(String destination) async {
    if (!state.destinations.contains(destination)) {
      final updated = state.copyWith(
        destinations: [...state.destinations, destination],
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }

  /// حذف وجهة
  Future<void> removeDestination(String destination) async {
    if (state.destinations.length > 1) {
      final updated = state.copyWith(
        destinations:
            state.destinations.where((d) => d != destination).toList(),
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }

  /// إضافة وكيل جديد
  Future<void> addAgent(String agent) async {
    if (!state.agents.contains(agent)) {
      final updated = state.copyWith(
        agents: [...state.agents, agent],
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }

  /// حذف وكيل
  Future<void> removeAgent(String agent) async {
    if (state.agents.length > 1) {
      final updated = state.copyWith(
        agents: state.agents.where((a) => a != agent).toList(),
      );
      await _repository.saveSettings(updated);
      state = updated;
    }
  }
}

// ─── Providers مشتقة ──────────────────────────────────────────────────────────

/// اسم الشركة الحالي
final companyNameProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).companyName;
});

/// اسم الفرع الحالي
final branchNameProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).branchName;
});

/// اسم الموظف الافتراضي
final defaultEmployeeNameProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultEmployeeName;
});

/// وضع الثيم
final themeModeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// العملة الافتراضية
final defaultCurrencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultCurrency;
});

/// الوجهة الافتراضية
final defaultDestinationProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultDestination;
});

/// الوكيل الافتراضي
final defaultAgentProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultAgent;
});

/// قائمة العملات المتاحة
final availableCurrenciesProvider = Provider<List<String>>((ref) {
  return ref.watch(settingsProvider).currencies;
});

/// قائمة الوجهات المتاحة
final availableDestinationsProvider = Provider<List<String>>((ref) {
  return ref.watch(settingsProvider).destinations;
});

/// قائمة الوكلاء المتاحة
final availableAgentsProvider = Provider<List<String>>((ref) {
  return ref.watch(settingsProvider).agents;
});

/// هل تُعرض المبالغ في القائمة؟
final showAmountsInListProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).showAmountsInList;
});

/// هل تظهر المؤثرات الحركية؟
final showAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).showAnimations;
});

/// الوضع المضغوط
final compactModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).compactMode;
});
