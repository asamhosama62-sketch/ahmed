// =============================================================================
// شاشة النسخ الاحتياطي - تطبيق العكابي
// =============================================================================
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/providers/transfer_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('النسخ الاحتياطي والاستعادة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── حالة آخر نسخة ────────────────────────────────────
            GradientCard(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.1),
                  scheme.primaryContainer.withValues(alpha: 0.2),
                ],
              ),
              border: true,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.backup_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'آخر نسخة احتياطية',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settings.lastBackupDate != null
                              ? ArabicFormatters.formatDateTime(
                                  settings.lastBackupDate!,
                                )
                              : 'لم يتم إنشاء نسخة بعد',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── النسخ الاحتياطي التلقائي ─────────────────────────
            const SectionHeader(
              title: 'النسخ الاحتياطي التلقائي',
              icon: Icons.schedule_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('تفعيل النسخ التلقائي'),
                    subtitle: const Text(
                      'يحفظ نسخة احتياطية تلقائياً بشكل دوري',
                    ),
                    secondary: const Icon(Icons.auto_awesome_rounded),
                    value: settings.autoBackupEnabled,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateSettings(
                          settings.copyWith(autoBackupEnabled: v),
                        ),
                    activeThumbColor: scheme.primary,
                  ),
                  if (settings.autoBackupEnabled) ...[
                    const AkabDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'كل كم يوم',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'الفترة بين كل نسخة وأخرى',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownButton<int>(
                            value: settings.backupIntervalDays,
                            items: [1, 3, 7, 14, 30].map((days) {
                              return DropdownMenuItem(
                                value: days,
                                child: Text(
                                  'كل ${ArabicFormatters.toArabicDigits(days.toString())} ${days == 1 ? 'يوم' : 'أيام'}',
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSettings(
                                      settings.copyWith(backupIntervalDays: v),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── تصدير واستيراد ────────────────────────────────────
            const SectionHeader(
              title: 'تصدير البيانات',
              icon: Icons.import_export_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // تصدير الحوالات كـ JSON
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_download_rounded,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('تصدير الحوالات (JSON)'),
                    subtitle: const Text('جميع الحوالات في ملف JSON'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _exportTransfers(context, ref),
                  ),
                  const AkabDivider(),
                  // تصدير الإعدادات
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.settings_backup_restore_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text('تصدير الإعدادات'),
                    subtitle: const Text('نسخ احتياطي لإعدادات التطبيق'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _exportSettings(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransfers(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(transferRepositoryProvider);
      final active = await repo.getAll(archived: false);
      final archived = await repo.getAll(archived: true);
      final all = [...active, ...archived];

      final data = jsonEncode(all.map((r) => r.toMap()).toList());
      final dir = await getTemporaryDirectory();
      final fileName =
          'العكابي_حوالات_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(data, encoding: utf8);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/json'),
      ], subject: 'تصدير الحوالات - تطبيق العكابي');

      await ref.read(settingsProvider.notifier).recordBackup();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في التصدير: $e')));
      }
    }
  }

  Future<void> _exportSettings(BuildContext context, WidgetRef ref) async {
    try {
      final settings = ref.read(settingsProvider);
      final repo = SettingsRepository.instance;
      final jsonStr = repo.exportSettingsJson(settings);

      final dir = await getTemporaryDirectory();
      final fileName =
          'العكابي_إعدادات_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr, encoding: utf8);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/json'),
      ], subject: 'إعدادات تطبيق العكابي');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في التصدير: $e')));
      }
    }
  }
}
