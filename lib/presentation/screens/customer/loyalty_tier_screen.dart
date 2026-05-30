import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/customer/customer.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class LoyaltyTierScreen extends ConsumerWidget {
  const LoyaltyTierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final customersAsync = ref.watch(allCustomersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('برنامج الولاء'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GradientCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF6C63FF), const Color(0xFF3F3D99)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'برنامج الولاء والمكافآت',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'كلما زادت حوالاتك، زادت نقاطك وخصوماتك!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'مستويات العضوية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _TierCard(
              tier: LoyaltyTier.regular,
              label: 'عادي',
              icon: Icons.person,
              color: Colors.grey,
              discount: '0%',
              requirement: 'أي عميل جديد',
              scheme: scheme,
            ),
            _TierCard(
              tier: LoyaltyTier.silver,
              label: 'فضي',
              icon: Icons.circle,
              color: const Color(0xFF9E9E9E),
              discount: '5%',
              requirement: '20+ حوالة أو 250,000+ ريال',
              scheme: scheme,
            ),
            _TierCard(
              tier: LoyaltyTier.gold,
              label: 'ذهبي',
              icon: Icons.star,
              color: const Color(0xFFFFB800),
              discount: '10%',
              requirement: '50+ حوالة أو 1,000,000+ ريال',
              scheme: scheme,
            ),
            _TierCard(
              tier: LoyaltyTier.platinum,
              label: 'بلاتيني',
              icon: Icons.diamond,
              color: const Color(0xFF6C63FF),
              discount: '20%',
              requirement: '100+ حوالة أو 5,000,000+ ريال',
              scheme: scheme,
            ),
            const SizedBox(height: 24),
            Text(
              'توزيع العملاء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    message: 'لا يوجد عملاء بعد',
                  );
                }
                final counts = {
                  LoyaltyTier.regular: 0,
                  LoyaltyTier.silver: 0,
                  LoyaltyTier.gold: 0,
                  LoyaltyTier.platinum: 0,
                };
                for (final c in customers) {
                  counts[c.tier] = (counts[c.tier] ?? 0) + 1;
                }
                final total = customers.length;

                return Column(
                  children: counts.entries.map((e) {
                    final percentage =
                        total > 0 ? (e.value / total) * 100 : 0.0;
                    final tierColors = _tierColor(e.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(tierColors.$3,
                                  color: tierColors.$2, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                tierColors.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${e.value} عميل (${percentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor:
                                  scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(
                                  tierColors.$2),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, IconData) _tierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.regular:
        return ('عادي', Colors.grey, Icons.person);
      case LoyaltyTier.silver:
        return ('فضي', const Color(0xFF9E9E9E), Icons.circle);
      case LoyaltyTier.gold:
        return ('ذهبي', const Color(0xFFFFB800), Icons.star);
      case LoyaltyTier.platinum:
        return ('بلاتيني', const Color(0xFF6C63FF), Icons.diamond);
    }
  }
}

class _TierCard extends StatelessWidget {
  final LoyaltyTier tier;
  final String label;
  final IconData icon;
  final Color color;
  final String discount;
  final String requirement;
  final ColorScheme scheme;

  const _TierCard({
    required this.tier,
    required this.label,
    required this.icon,
    required this.color,
    required this.discount,
    required this.requirement,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'خصم $discount',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  requirement,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
