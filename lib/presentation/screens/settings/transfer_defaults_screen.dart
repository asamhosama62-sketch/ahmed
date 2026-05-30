// =============================================================================
// شاشة إعدادات الحوالة الافتراضية - تطبيق العكابي
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/arabic_formatters.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class TransferDefaultsScreen extends ConsumerStatefulWidget {
  const TransferDefaultsScreen({super.key});

  @override
  ConsumerState<TransferDefaultsScreen> createState() =>
      _TransferDefaultsScreenState();
}

class _TransferDefaultsScreenState
    extends ConsumerState<TransferDefaultsScreen> {
  late TextEditingController _feeCtrl;
  late TextEditingController _minFeeCtrl;
  late TextEditingController _newCurrencyCtrl;
  late TextEditingController _newDestCtrl;
  late TextEditingController _newAgentCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _feeCtrl = TextEditingController(text: s.defaultFeePercentage.toString());
    _minFeeCtrl = TextEditingController(text: s.minimumFee.toString());
    _newCurrencyCtrl = TextEditingController();
    _newDestCtrl = TextEditingController();
    _newAgentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _minFeeCtrl.dispose();
    _newCurrencyCtrl.dispose();
    _newDestCtrl.dispose();
    _newAgentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إعدادات الحوالة الافتراضية')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── العملة الافتراضية ────────────────────────────────
            const SectionHeader(
              title: 'العملات المتاحة',
              icon: Icons.currency_exchange_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: settings.currencies.map((cur) {
                      final isDefault = cur == settings.defaultCurrency;
                      return InputChip(
                        label: Text(cur),
                        selected: isDefault,
                        onPressed: () async {
                          await notifier.updateTransferDefaults(currency: cur);
                        },
                        onDeleted: settings.currencies.length > 1
                            ? () => notifier.removeCurrency(cur)
                            : null,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        selectedColor: scheme.primaryContainer,
                        checkmarkColor: scheme.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCurrencyCtrl,
                          decoration: const InputDecoration(
                            hintText: 'إضافة عملة جديدة...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () async {
                          final val = _newCurrencyCtrl.text.trim();
                          if (val.isNotEmpty) {
                            await notifier.addCurrency(val);
                            _newCurrencyCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── الوجهات المتاحة ──────────────────────────────────
            const SectionHeader(
              title: 'الوجهات المتاحة',
              icon: Icons.send_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  ...settings.destinations.map((dest) {
                    final isDefault = dest == settings.defaultDestination;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () =>
                          notifier.updateTransferDefaults(destination: dest),
                      leading: Icon(
                        isDefault
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isDefault
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      title: Text(
                        dest,
                        style: TextStyle(
                          fontWeight: isDefault
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: settings.destinations.length > 1
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () => notifier.removeDestination(dest),
                            )
                          : null,
                    );
                  }),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newDestCtrl,
                          decoration: const InputDecoration(
                            hintText: 'إضافة وجهة جديدة...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () async {
                          final val = _newDestCtrl.text.trim();
                          if (val.isNotEmpty) {
                            await notifier.addDestination(val);
                            _newDestCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── الوكلاء المتاحون ─────────────────────────────────
            const SectionHeader(
              title: 'الوكلاء المتاحون',
              icon: Icons.account_balance_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  ...settings.agents.map((agent) {
                    final isDefault = agent == settings.defaultAgent;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () =>
                          notifier.updateTransferDefaults(agent: agent),
                      leading: Icon(
                        isDefault
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isDefault
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      title: Text(
                        agent,
                        style: TextStyle(
                          fontWeight: isDefault
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                      trailing: settings.agents.length > 1
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () => notifier.removeAgent(agent),
                            )
                          : null,
                    );
                  }),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newAgentCtrl,
                          decoration: const InputDecoration(
                            hintText: 'إضافة وكيل جديد...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () async {
                          final val = _newAgentCtrl.text.trim();
                          if (val.isNotEmpty) {
                            await notifier.addAgent(val);
                            _newAgentCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── الرسوم الافتراضية ────────────────────────────────
            const SectionHeader(
              title: 'الرسوم الافتراضية',
              icon: Icons.percent_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _feeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'نسبة الرسوم الافتراضية (%)',
                      prefixIcon: Icon(Icons.percent_rounded),
                      suffix: Text('%'),
                    ),
                    onChanged: (v) async {
                      final pct = double.tryParse(
                        ArabicFormatters.toWesternDigits(v),
                      );
                      if (pct != null) {
                        await notifier.updateTransferDefaults(
                          feePercentage: pct,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _minFeeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'الحد الأدنى للرسوم',
                      prefixIcon: Icon(Icons.money_rounded),
                    ),
                    onChanged: (v) async {
                      final fee = double.tryParse(
                        ArabicFormatters.toWesternDigits(v),
                      );
                      if (fee != null) {
                        await notifier.updateTransferDefaults(minimumFee: fee);
                      }
                    },
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
}
