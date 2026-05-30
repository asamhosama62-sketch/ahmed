import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/customer/customer.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final customersAsync = ref.watch(allCustomersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل العميل'),
        ),
        body: customersAsync.when(
          data: (customers) {
            final customer = customers.where((c) => c.id == customerId).firstOrNull;
            if (customer == null) {
              return const EmptyStateWidget(
                icon: Icons.person_off,
                message: 'العميل غير موجود',
              );
            }
            return _CustomerDetailContent(
                customer: customer, scheme: scheme);
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _CustomerDetailContent extends StatelessWidget {
  final Customer customer;
  final ColorScheme scheme;

  const _CustomerDetailContent({
    required this.customer,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final tierColors = _getTierColors();
    final f = DateFormat.yMMMd('ar');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GradientCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tierColors[0], tierColors[1]],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  customer.name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${customer.tierLabel} • ${customer.loyaltyPoints} نقطة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'معلومات العميل', scheme: scheme),
        const SizedBox(height: 8),
        _InfoRow(
          label: 'رقم الهاتف',
          value: customer.phone,
          scheme: scheme,
        ),
        if (customer.secondaryPhone != null)
          _InfoRow(
            label: 'هاتف بديل',
            value: customer.secondaryPhone!,
            scheme: scheme,
          ),
        _InfoRow(
          label: 'العملة المفضلة',
          value: customer.preferredCurrency ?? 'غير محدد',
          scheme: scheme,
        ),
        _InfoRow(
          label: 'الوكيل المفضل',
          value: customer.preferredAgent ?? 'غير محدد',
          scheme: scheme,
        ),
        _InfoRow(
          label: 'تاريخ أول معاملة',
          value: f.format(customer.firstTransactionDate),
          scheme: scheme,
        ),
        _InfoRow(
          label: 'آخر معاملة',
          value: f.format(customer.lastTransactionDate),
          scheme: scheme,
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'إحصائيات المعاملات', scheme: scheme),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'حوالات مرسلة',
                value: '${customer.totalTransfersSent}',
                icon: Icons.arrow_upward,
                color: Colors.green,
                scheme: scheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'حوالات مستلمة',
                value: '${customer.totalTransfersReceived}',
                icon: Icons.arrow_downward,
                color: Colors.blue,
                scheme: scheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'إجمالي مرسل',
                value: ArabicFormatters.formatAmount(customer.totalAmountSent),
                icon: Icons.payments,
                color: Colors.orange,
                scheme: scheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'إجمالي مستلم',
                value:
                    ArabicFormatters.formatAmount(customer.totalAmountReceived),
                icon: Icons.account_balance_wallet,
                color: Colors.purple,
                scheme: scheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'برنامج الولاء', scheme: scheme),
        const SizedBox(height: 8),
        _buildLoyaltyCard(scheme, tierColors),
        const SizedBox(height: 20),
        _SectionTitle(title: 'خصم العمولة', scheme: scheme),
        const SizedBox(height: 8),
        GradientCard(
          color: scheme.primaryContainer,
          child: Row(
            children: [
              Icon(Icons.discount, color: scheme.onPrimaryContainer, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نسبة الخصم الممنوحة',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${(customer.discountRate * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (customer.notes != null && customer.notes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(title: 'ملاحظات', scheme: scheme),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(customer.notes!),
          ),
        ],
      ],
    );
  }

  Widget _buildLoyaltyCard(ColorScheme scheme, List<Color> tierColors) {
    final tiers = [
      (LoyaltyTier.regular, 'عادي', '0%', Icons.person, Colors.grey),
      (LoyaltyTier.silver, 'فضي', '5%', Icons.circle, Colors.grey.shade400),
      (LoyaltyTier.gold, 'ذهبي', '10%', Icons.star, Colors.amber),
      (LoyaltyTier.platinum, 'بلاتيني', '20%', Icons.diamond, Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          ...tiers.map((t) {
            final isCurrent = customer.tier == t.$1;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? tierColors[0].withValues(alpha: 0.1)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(color: tierColors[0], width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(t.$4, color: t.$5, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.$2,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    'خصم ${t.$3}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_circle,
                          color: tierColors[0], size: 20),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Color> _getTierColors() {
    switch (customer.tier) {
      case LoyaltyTier.platinum:
        return [const Color(0xFF6C63FF), const Color(0xFF3F3D99)];
      case LoyaltyTier.gold:
        return [const Color(0xFFFFB800), const Color(0xFFCC9300)];
      case LoyaltyTier.silver:
        return [const Color(0xFF9E9E9E), const Color(0xFF757575)];
      case LoyaltyTier.regular:
        return [Colors.blue, Colors.blue.shade700];
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ColorScheme scheme;

  const _SectionTitle({required this.title, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
