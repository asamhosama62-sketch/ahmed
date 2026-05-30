import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/customer/customer.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/shared_widgets.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() =>
      _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final customersAsync = ref.watch(filteredCustomersProvider);
    final countAsync = ref.watch(customerCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة العملاء'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(filteredCustomersProvider);
                ref.invalidate(customerCountProvider);
              },
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  ref.read(customerSearchQueryProvider.notifier).state = v;
                },
                decoration: InputDecoration(
                  hintText: 'بحث باسم العميل أو رقم الهاتف...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(customerSearchQueryProvider.notifier)
                                .state = '';
                          },
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.people, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'إجمالي العملاء: ${countAsync.asData?.value ?? 0}',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: customersAsync.when(
                data: (customers) {
                  if (customers.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      message: 'لا يوجد عملاء بعد',
                      subtitle: 'سيتم إضافة العملاء تلقائياً عند إنشاء الحوالات',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) =>
                        _CustomerCard(
                            customer: customers[index], scheme: scheme),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, _) => EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: 'خطأ: $e',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final ColorScheme scheme;

  const _CustomerCard({required this.customer, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final tierColors = _getTierColors();

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
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  CustomerDetailScreen(customerId: customer.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: tierColors[0].withValues(alpha: 0.15),
                  child: Text(
                    customer.name.substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: tierColors[0],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: tierColors,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customer.tierLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.swap_horiz,
                  label: '${customer.totalTransactions} حوالة',
                  scheme: scheme,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.stars,
                  label: '${customer.loyaltyPoints} نقطة',
                  scheme: scheme,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.monetization_on,
                  label: ArabicFormatters.formatAmount(customer.totalVolume),
                  scheme: scheme,
                ),
              ],
            ),
          ],
        ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
