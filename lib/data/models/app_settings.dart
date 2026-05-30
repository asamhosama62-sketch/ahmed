// =============================================================================
// نموذج إعدادات التطبيق - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'package:flutter/material.dart';

/// نموذج شامل لجميع إعدادات التطبيق القابلة للتخصيص
class AppSettings {
  const AppSettings({
    // ─── بيانات الشركة ─────────────────────────────────────────────────────
    required this.companyName,
    required this.companyNameEn,
    required this.branchName,
    required this.companyPhones,
    required this.companyAddress,
    required this.companyEmail,
    required this.companyWebsite,
    required this.companyLicenseNumber,
    required this.companyCRNumber,
    // ─── بيانات الموظف ─────────────────────────────────────────────────────
    required this.defaultEmployeeName,
    required this.defaultEmployeeId,
    required this.defaultEmployeeSignature,
    required this.defaultEmployeePhone,
    required this.defaultEmployeePosition,
    // ─── إعدادات الحوالة ────────────────────────────────────────────────────
    required this.defaultCurrency,
    required this.defaultAgent,
    required this.defaultDestination,
    required this.defaultFeePercentage,
    required this.minimumFee,
    required this.currencies,
    required this.destinations,
    required this.agents,
    // ─── إعدادات الطباعة ────────────────────────────────────────────────────
    required this.defaultPrintFormat,
    required this.printCopies,
    required this.showQrCode,
    required this.showCompanyLogo,
    required this.thermalPaperWidth,
    required this.pdfMargin,
    required this.fontSizePdf,
    // ─── إعدادات الواجهة ────────────────────────────────────────────────────
    required this.themeMode,
    required this.primaryColorHex,
    required this.language,
    required this.useArabicNumerals,
    required this.dateFormat,
    required this.showAnimations,
    required this.compactMode,
    // ─── إعدادات النسخ الاحتياطي ────────────────────────────────────────────
    required this.autoBackupEnabled,
    required this.backupIntervalDays,
    required this.lastBackupDate,
    required this.backupPath,
    // ─── إعدادات الأمان ─────────────────────────────────────────────────────
    required this.requirePinToOpen,
    required this.pinCode,
    required this.sessionTimeoutMinutes,
    required this.showAmountsInList,
    // ─── إعدادات الإشعارات ──────────────────────────────────────────────────
    required this.notifyOnNewTransfer,
    required this.notifyOnDailyReport,
    required this.dailyReportTime,
    // ─── إعدادات متقدمة ─────────────────────────────────────────────────────
    required this.receiptPrefix,
    required this.startingReceiptNumber,
    required this.autoArchiveAfterDays,
    required this.showDemoData,
    required this.version,
    required this.lastModified,
  });

  // ─── بيانات الشركة ─────────────────────────────────────────────────────────
  final String companyName;
  final String companyNameEn;
  final String branchName;
  final String companyPhones;
  final String companyAddress;
  final String companyEmail;
  final String companyWebsite;
  final String companyLicenseNumber;
  final String companyCRNumber;

  // ─── بيانات الموظف ─────────────────────────────────────────────────────────
  final String defaultEmployeeName;
  final String defaultEmployeeId;
  final String defaultEmployeeSignature;
  final String defaultEmployeePhone;
  final String defaultEmployeePosition;

  // ─── إعدادات الحوالة ───────────────────────────────────────────────────────
  final String defaultCurrency;
  final String defaultAgent;
  final String defaultDestination;
  final double defaultFeePercentage;
  final double minimumFee;
  final List<String> currencies;
  final List<String> destinations;
  final List<String> agents;

  // ─── إعدادات الطباعة ───────────────────────────────────────────────────────
  final String defaultPrintFormat; // 'a4' | 'thermal80' | 'thermal58'
  final int printCopies;
  final bool showQrCode;
  final bool showCompanyLogo;
  final double thermalPaperWidth;
  final double pdfMargin;
  final double fontSizePdf;

  // ─── إعدادات الواجهة ───────────────────────────────────────────────────────
  final String themeMode; // 'system' | 'light' | 'dark'
  final String primaryColorHex;
  final String language; // 'ar' | 'en'
  final bool useArabicNumerals;
  final String dateFormat;
  final bool showAnimations;
  final bool compactMode;

  // ─── إعدادات النسخ الاحتياطي ───────────────────────────────────────────────
  final bool autoBackupEnabled;
  final int backupIntervalDays;
  final DateTime? lastBackupDate;
  final String backupPath;

  // ─── إعدادات الأمان ────────────────────────────────────────────────────────
  final bool requirePinToOpen;
  final String pinCode;
  final int sessionTimeoutMinutes;
  final bool showAmountsInList;

  // ─── إعدادات الإشعارات ─────────────────────────────────────────────────────
  final bool notifyOnNewTransfer;
  final bool notifyOnDailyReport;
  final String dailyReportTime; // 'HH:mm'

  // ─── إعدادات متقدمة ────────────────────────────────────────────────────────
  final String receiptPrefix;
  final int startingReceiptNumber;
  final int autoArchiveAfterDays;
  final bool showDemoData;
  final String version;
  final DateTime lastModified;

  // ─── الثيم المستمد من الإعدادات ────────────────────────────────────────────
  ThemeMode get resolvedThemeMode {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Color get primaryColor {
    try {
      final hex = primaryColorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF1A4B8B); // اللون الافتراضي للعكابي
  }

  // ─── القيم الافتراضية ──────────────────────────────────────────────────────
  static AppSettings defaultSettings() {
    return AppSettings(
      // بيانات الشركة
      companyName: 'العكابي للصرافة والتحويلات',
      companyNameEn: 'Al-Akabi Exchange & Money Transfer',
      branchName: 'الفرع الرئيسي',
      companyPhones: '04249669 - 777245365 - 734166329',
      companyAddress: 'بير باشا - أمام محطة الحزام',
      companyEmail: 'info@alakabi.com',
      companyWebsite: 'www.alakabi.com',
      companyLicenseNumber: '',
      companyCRNumber: '',
      // بيانات الموظف
      defaultEmployeeName: 'الموظف',
      defaultEmployeeId: '',
      defaultEmployeeSignature: '',
      defaultEmployeePhone: '',
      defaultEmployeePosition: 'موظف حوالات',
      // إعدادات الحوالة
      defaultCurrency: 'سعودي',
      defaultAgent: 'البنك الأهلي للتمويل الأصغر الإسلامي',
      defaultDestination: 'كريمي إكسبرس',
      defaultFeePercentage: 2.0,
      minimumFee: 1.0,
      currencies: ['سعودي', 'دولار', 'يورو', 'درهم', 'دينار', 'جنيه', 'ريال قطري'],
      destinations: [
        'كريمي إكسبرس',
        'وسترن يونيون',
        'مني غرام',
        'تحويل بنكي',
        'ريا',
        'ورلدريميت',
      ],
      agents: [
        'البنك الأهلي للتمويل الأصغر الإسلامي',
        'بنك اليمن والخليج',
        'البنك العربي',
        'بنك التضامن الإسلامي',
      ],
      // إعدادات الطباعة
      defaultPrintFormat: 'a4',
      printCopies: 1,
      showQrCode: true,
      showCompanyLogo: true,
      thermalPaperWidth: 80.0,
      pdfMargin: 22.0,
      fontSizePdf: 10.0,
      // إعدادات الواجهة
      themeMode: 'system',
      primaryColorHex: '#1A4B8B',
      language: 'ar',
      useArabicNumerals: true,
      dateFormat: 'yyyy/MM/dd',
      showAnimations: true,
      compactMode: false,
      // إعدادات النسخ الاحتياطي
      autoBackupEnabled: false,
      backupIntervalDays: 7,
      lastBackupDate: null,
      backupPath: '',
      // إعدادات الأمان
      requirePinToOpen: false,
      pinCode: '',
      sessionTimeoutMinutes: 30,
      showAmountsInList: true,
      // إعدادات الإشعارات
      notifyOnNewTransfer: true,
      notifyOnDailyReport: false,
      dailyReportTime: '08:00',
      // إعدادات متقدمة
      receiptPrefix: 'R',
      startingReceiptNumber: 1000,
      autoArchiveAfterDays: 90,
      showDemoData: false,
      version: '1.0.0',
      lastModified: DateTime.now(),
    );
  }

  // ─── copyWith ──────────────────────────────────────────────────────────────
  AppSettings copyWith({
    String? companyName,
    String? companyNameEn,
    String? branchName,
    String? companyPhones,
    String? companyAddress,
    String? companyEmail,
    String? companyWebsite,
    String? companyLicenseNumber,
    String? companyCRNumber,
    String? defaultEmployeeName,
    String? defaultEmployeeId,
    String? defaultEmployeeSignature,
    String? defaultEmployeePhone,
    String? defaultEmployeePosition,
    String? defaultCurrency,
    String? defaultAgent,
    String? defaultDestination,
    double? defaultFeePercentage,
    double? minimumFee,
    List<String>? currencies,
    List<String>? destinations,
    List<String>? agents,
    String? defaultPrintFormat,
    int? printCopies,
    bool? showQrCode,
    bool? showCompanyLogo,
    double? thermalPaperWidth,
    double? pdfMargin,
    double? fontSizePdf,
    String? themeMode,
    String? primaryColorHex,
    String? language,
    bool? useArabicNumerals,
    String? dateFormat,
    bool? showAnimations,
    bool? compactMode,
    bool? autoBackupEnabled,
    int? backupIntervalDays,
    DateTime? lastBackupDate,
    String? backupPath,
    bool? requirePinToOpen,
    String? pinCode,
    int? sessionTimeoutMinutes,
    bool? showAmountsInList,
    bool? notifyOnNewTransfer,
    bool? notifyOnDailyReport,
    String? dailyReportTime,
    String? receiptPrefix,
    int? startingReceiptNumber,
    int? autoArchiveAfterDays,
    bool? showDemoData,
    String? version,
    DateTime? lastModified,
  }) {
    return AppSettings(
      companyName: companyName ?? this.companyName,
      companyNameEn: companyNameEn ?? this.companyNameEn,
      branchName: branchName ?? this.branchName,
      companyPhones: companyPhones ?? this.companyPhones,
      companyAddress: companyAddress ?? this.companyAddress,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      companyLicenseNumber: companyLicenseNumber ?? this.companyLicenseNumber,
      companyCRNumber: companyCRNumber ?? this.companyCRNumber,
      defaultEmployeeName: defaultEmployeeName ?? this.defaultEmployeeName,
      defaultEmployeeId: defaultEmployeeId ?? this.defaultEmployeeId,
      defaultEmployeeSignature:
          defaultEmployeeSignature ?? this.defaultEmployeeSignature,
      defaultEmployeePhone: defaultEmployeePhone ?? this.defaultEmployeePhone,
      defaultEmployeePosition:
          defaultEmployeePosition ?? this.defaultEmployeePosition,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultAgent: defaultAgent ?? this.defaultAgent,
      defaultDestination: defaultDestination ?? this.defaultDestination,
      defaultFeePercentage: defaultFeePercentage ?? this.defaultFeePercentage,
      minimumFee: minimumFee ?? this.minimumFee,
      currencies: currencies ?? this.currencies,
      destinations: destinations ?? this.destinations,
      agents: agents ?? this.agents,
      defaultPrintFormat: defaultPrintFormat ?? this.defaultPrintFormat,
      printCopies: printCopies ?? this.printCopies,
      showQrCode: showQrCode ?? this.showQrCode,
      showCompanyLogo: showCompanyLogo ?? this.showCompanyLogo,
      thermalPaperWidth: thermalPaperWidth ?? this.thermalPaperWidth,
      pdfMargin: pdfMargin ?? this.pdfMargin,
      fontSizePdf: fontSizePdf ?? this.fontSizePdf,
      themeMode: themeMode ?? this.themeMode,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      language: language ?? this.language,
      useArabicNumerals: useArabicNumerals ?? this.useArabicNumerals,
      dateFormat: dateFormat ?? this.dateFormat,
      showAnimations: showAnimations ?? this.showAnimations,
      compactMode: compactMode ?? this.compactMode,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupIntervalDays: backupIntervalDays ?? this.backupIntervalDays,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      backupPath: backupPath ?? this.backupPath,
      requirePinToOpen: requirePinToOpen ?? this.requirePinToOpen,
      pinCode: pinCode ?? this.pinCode,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      showAmountsInList: showAmountsInList ?? this.showAmountsInList,
      notifyOnNewTransfer: notifyOnNewTransfer ?? this.notifyOnNewTransfer,
      notifyOnDailyReport: notifyOnDailyReport ?? this.notifyOnDailyReport,
      dailyReportTime: dailyReportTime ?? this.dailyReportTime,
      receiptPrefix: receiptPrefix ?? this.receiptPrefix,
      startingReceiptNumber:
          startingReceiptNumber ?? this.startingReceiptNumber,
      autoArchiveAfterDays: autoArchiveAfterDays ?? this.autoArchiveAfterDays,
      showDemoData: showDemoData ?? this.showDemoData,
      version: version ?? this.version,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  // ─── تحويل من/إلى Map ──────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'companyNameEn': companyNameEn,
      'branchName': branchName,
      'companyPhones': companyPhones,
      'companyAddress': companyAddress,
      'companyEmail': companyEmail,
      'companyWebsite': companyWebsite,
      'companyLicenseNumber': companyLicenseNumber,
      'companyCRNumber': companyCRNumber,
      'defaultEmployeeName': defaultEmployeeName,
      'defaultEmployeeId': defaultEmployeeId,
      'defaultEmployeeSignature': defaultEmployeeSignature,
      'defaultEmployeePhone': defaultEmployeePhone,
      'defaultEmployeePosition': defaultEmployeePosition,
      'defaultCurrency': defaultCurrency,
      'defaultAgent': defaultAgent,
      'defaultDestination': defaultDestination,
      'defaultFeePercentage': defaultFeePercentage,
      'minimumFee': minimumFee,
      'currencies': currencies.join('|'),
      'destinations': destinations.join('|'),
      'agents': agents.join('|'),
      'defaultPrintFormat': defaultPrintFormat,
      'printCopies': printCopies,
      'showQrCode': showQrCode,
      'showCompanyLogo': showCompanyLogo,
      'thermalPaperWidth': thermalPaperWidth,
      'pdfMargin': pdfMargin,
      'fontSizePdf': fontSizePdf,
      'themeMode': themeMode,
      'primaryColorHex': primaryColorHex,
      'language': language,
      'useArabicNumerals': useArabicNumerals,
      'dateFormat': dateFormat,
      'showAnimations': showAnimations,
      'compactMode': compactMode,
      'autoBackupEnabled': autoBackupEnabled,
      'backupIntervalDays': backupIntervalDays,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'backupPath': backupPath,
      'requirePinToOpen': requirePinToOpen,
      'pinCode': pinCode,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'showAmountsInList': showAmountsInList,
      'notifyOnNewTransfer': notifyOnNewTransfer,
      'notifyOnDailyReport': notifyOnDailyReport,
      'dailyReportTime': dailyReportTime,
      'receiptPrefix': receiptPrefix,
      'startingReceiptNumber': startingReceiptNumber,
      'autoArchiveAfterDays': autoArchiveAfterDays,
      'showDemoData': showDemoData,
      'version': version,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final defaults = AppSettings.defaultSettings();
    return AppSettings(
      companyName: map['companyName'] as String? ?? defaults.companyName,
      companyNameEn:
          map['companyNameEn'] as String? ?? defaults.companyNameEn,
      branchName: map['branchName'] as String? ?? defaults.branchName,
      companyPhones:
          map['companyPhones'] as String? ?? defaults.companyPhones,
      companyAddress:
          map['companyAddress'] as String? ?? defaults.companyAddress,
      companyEmail: map['companyEmail'] as String? ?? defaults.companyEmail,
      companyWebsite:
          map['companyWebsite'] as String? ?? defaults.companyWebsite,
      companyLicenseNumber:
          map['companyLicenseNumber'] as String? ??
          defaults.companyLicenseNumber,
      companyCRNumber:
          map['companyCRNumber'] as String? ?? defaults.companyCRNumber,
      defaultEmployeeName:
          map['defaultEmployeeName'] as String? ??
          defaults.defaultEmployeeName,
      defaultEmployeeId:
          map['defaultEmployeeId'] as String? ?? defaults.defaultEmployeeId,
      defaultEmployeeSignature:
          map['defaultEmployeeSignature'] as String? ??
          defaults.defaultEmployeeSignature,
      defaultEmployeePhone:
          map['defaultEmployeePhone'] as String? ??
          defaults.defaultEmployeePhone,
      defaultEmployeePosition:
          map['defaultEmployeePosition'] as String? ??
          defaults.defaultEmployeePosition,
      defaultCurrency:
          map['defaultCurrency'] as String? ?? defaults.defaultCurrency,
      defaultAgent: map['defaultAgent'] as String? ?? defaults.defaultAgent,
      defaultDestination:
          map['defaultDestination'] as String? ?? defaults.defaultDestination,
      defaultFeePercentage:
          (map['defaultFeePercentage'] as num?)?.toDouble() ??
          defaults.defaultFeePercentage,
      minimumFee:
          (map['minimumFee'] as num?)?.toDouble() ?? defaults.minimumFee,
      currencies:
          (map['currencies'] as String?)?.split('|') ?? defaults.currencies,
      destinations:
          (map['destinations'] as String?)?.split('|') ??
          defaults.destinations,
      agents: (map['agents'] as String?)?.split('|') ?? defaults.agents,
      defaultPrintFormat:
          map['defaultPrintFormat'] as String? ?? defaults.defaultPrintFormat,
      printCopies:
          map['printCopies'] as int? ?? defaults.printCopies,
      showQrCode: map['showQrCode'] as bool? ?? defaults.showQrCode,
      showCompanyLogo:
          map['showCompanyLogo'] as bool? ?? defaults.showCompanyLogo,
      thermalPaperWidth:
          (map['thermalPaperWidth'] as num?)?.toDouble() ??
          defaults.thermalPaperWidth,
      pdfMargin:
          (map['pdfMargin'] as num?)?.toDouble() ?? defaults.pdfMargin,
      fontSizePdf:
          (map['fontSizePdf'] as num?)?.toDouble() ?? defaults.fontSizePdf,
      themeMode: map['themeMode'] as String? ?? defaults.themeMode,
      primaryColorHex:
          map['primaryColorHex'] as String? ?? defaults.primaryColorHex,
      language: map['language'] as String? ?? defaults.language,
      useArabicNumerals:
          map['useArabicNumerals'] as bool? ?? defaults.useArabicNumerals,
      dateFormat: map['dateFormat'] as String? ?? defaults.dateFormat,
      showAnimations:
          map['showAnimations'] as bool? ?? defaults.showAnimations,
      compactMode: map['compactMode'] as bool? ?? defaults.compactMode,
      autoBackupEnabled:
          map['autoBackupEnabled'] as bool? ?? defaults.autoBackupEnabled,
      backupIntervalDays:
          map['backupIntervalDays'] as int? ?? defaults.backupIntervalDays,
      lastBackupDate:
          map['lastBackupDate'] != null
              ? DateTime.tryParse(map['lastBackupDate'] as String)
              : null,
      backupPath: map['backupPath'] as String? ?? defaults.backupPath,
      requirePinToOpen:
          map['requirePinToOpen'] as bool? ?? defaults.requirePinToOpen,
      pinCode: map['pinCode'] as String? ?? defaults.pinCode,
      sessionTimeoutMinutes:
          map['sessionTimeoutMinutes'] as int? ??
          defaults.sessionTimeoutMinutes,
      showAmountsInList:
          map['showAmountsInList'] as bool? ?? defaults.showAmountsInList,
      notifyOnNewTransfer:
          map['notifyOnNewTransfer'] as bool? ?? defaults.notifyOnNewTransfer,
      notifyOnDailyReport:
          map['notifyOnDailyReport'] as bool? ?? defaults.notifyOnDailyReport,
      dailyReportTime:
          map['dailyReportTime'] as String? ?? defaults.dailyReportTime,
      receiptPrefix:
          map['receiptPrefix'] as String? ?? defaults.receiptPrefix,
      startingReceiptNumber:
          map['startingReceiptNumber'] as int? ??
          defaults.startingReceiptNumber,
      autoArchiveAfterDays:
          map['autoArchiveAfterDays'] as int? ?? defaults.autoArchiveAfterDays,
      showDemoData: map['showDemoData'] as bool? ?? defaults.showDemoData,
      version: map['version'] as String? ?? defaults.version,
      lastModified:
          map['lastModified'] != null
              ? DateTime.tryParse(map['lastModified'] as String) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }
}
