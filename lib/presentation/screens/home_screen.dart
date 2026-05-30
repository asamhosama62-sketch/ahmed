
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/arabic_formatters.dart';
import '../../data/models/transfer_receipt.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../providers/transfer_providers.dart';
import '../widgets/common/shared_widgets.dart';
import 'receipt_preview_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'system_menu_screen.dart';
import 'transfer_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;
  String _query = '';
  int _navIndex = 0; // 0=الرئيسية, 1=الإحصائيات, 2=الإعدادات, 3=النظام

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(
      () => setState(() => _query = _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeTab(scheme),
            const StatisticsScreen(),
            const SettingsScreen(),
            const SystemMenuScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(scheme),
        floatingActionButton: _navIndex == 0
            ? FloatingActionButton.extended(
                heroTag: 'new_transfer_fab',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TransferFormScreen()),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('حوالة جديدة'),
              )
            : null,
      ),
    );
  }

  // ─── شريط التنقل السفلي ───────────────────────────────────────────────────
  Widget _buildBottomNav(ColorScheme scheme) {
    return NavigationBar(
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
      backgroundColor: scheme.surface,
      elevation: 0,
      indicatorColor: scheme.primaryContainer,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'الإحصائيات',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'الإعدادات',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'النظام',
        ),
      ],
    );
  }

  // ─── تاب الحوالات الرئيسي ─────────────────────────────────────────────────
  Widget _buildHomeTab(ColorScheme scheme) {
    final transfers = ref.watch(activeTransfersProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // ─── Header الاحترافي ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              snap: false,
              backgroundColor: scheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _HeaderBackground(settings: settings),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'بحث برقم الحوالة أو الاسم أو الهاتف...',
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                    ],
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                settings.companyName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ─── شريط الإحصائيات السريعة ───────────────────────────
            SliverToBoxAdapter(child: _QuickStatsBar()),

            // ─── تاب بار ───────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.receipt_long_rounded, size: 18),
                      text: 'النشطة',
                    ),
                    Tab(
                      icon: Icon(Icons.archive_rounded, size: 18),
                      text: 'الأرشيف',
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // ─── الحوالات النشطة ──────────────────────────────────
              transfers.when(
                data: (items) => _TransferList(
                  receipts: _filter(items),
                  emptyText: 'لا توجد حوالات نشطة',
                  emptySubtitle: 'اضغط زر "+" لإضافة حوالة جديدة',
                  emptyIcon: Icons.receipt_long_rounded,
                  onPreview: _preview,
                  onArchive: (r) => _archive(r, archived: true),
                  onDelete: _delete,
                ),
                error: (e, _) => _ErrorView(message: e.toString()),
                loading: () =>
                    const LoadingWidget(message: 'جارٍ تحميل الحوالات...'),
              ),

              // ─── الأرشيف ─────────────────────────────────────────
              FutureBuilder<List<TransferReceipt>>(
                future: ref
                    .read(activeTransfersProvider.notifier)
                    .search(_query, archived: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }
                  if (snapshot.hasError) {
                    return _ErrorView(message: snapshot.error.toString());
                  }
                  return _TransferList(
                    receipts: snapshot.data ?? [],
                    emptyText: 'لا توجد حوالات مؤرشفة',
                    emptySubtitle: 'الحوالات المؤرشفة تظهر هنا',
                    emptyIcon: Icons.archive_rounded,
                    onPreview: _preview,
                    onArchive: (r) => _archive(r, archived: false),
                    onDelete: _delete,
                    archiveLabel: 'استعادة',
                    archiveIcon: Icons.unarchive_rounded,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransferReceipt> _filter(List<TransferReceipt> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((r) {
      final text = [
        r.receiptNumber,
        r.transferNumber,
        r.referenceNumber,
        r.senderName,
        r.receiverName,
        r.senderPhone,
        r.receiverPhone,
        r.destination,
        r.employeeName,
      ].join(' ').toLowerCase();
      return text.contains(q);
    }).toList();
  }

  void _preview(TransferReceipt receipt) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReceiptPreviewScreen(receipt: receipt)),
    );
  }

  Future<void> _archive(
    TransferReceipt receipt, {
    required bool archived,
  }) async {
    await ref
        .read(activeTransfersProvider.notifier)
        .archive(receipt.id, archived: archived);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(archived ? 'تمت أرشفة الحوالة' : 'تمت استعادة الحوالة'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  Future<void> _delete(TransferReceipt receipt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف حوالة رقم ${ArabicFormatters.toArabicDigits(receipt.transferNumber)} نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(activeTransfersProvider.notifier).delete(receipt.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الحوالة نهائياً')));
    setState(() {});
  }
}

// =============================================================================
// خلفية الـ Header
// =============================================================================
class _HeaderBackground extends ConsumerWidget {
  const _HeaderBackground({required this.settings});

  final dynamic settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            scheme.primary.withValues(alpha: 0.12),
            scheme.primaryContainer.withValues(alpha: 0.08),
            scheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.companyName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${settings.branchName}  •  ${settings.companyPhones}',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// شريط الإحصائيات السريعة
// =============================================================================
class _QuickStatsBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardStatsProvider);
    final scheme = Theme.of(context).colorScheme;

    return dashAsync.when(
      loading: () => const SizedBox(height: 8),
      error: (_, __) => const SizedBox(height: 8),
      data: (dash) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            _MiniStatChip(
              label: 'اليوم',
              count: dash.todayCount,
              color: Colors.blue,
              icon: Icons.today_rounded,
            ),
            const SizedBox(width: 8),
            _MiniStatChip(
              label: 'الشهر',
              count: dash.monthCount,
              color: Colors.green,
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      size: 14,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ArabicFormatters.formatAmount(dash.monthAmount),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          const SizedBox(width: 4),
          Text(
            ArabicFormatters.toArabicDigits(count.toString()),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// قائمة الحوالات
// =============================================================================
class _TransferList extends ConsumerWidget {
  const _TransferList({
    required this.receipts,
    required this.emptyText,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.onPreview,
    required this.onArchive,
    required this.onDelete,
    this.archiveLabel = 'أرشفة',
    this.archiveIcon = Icons.archive_rounded,
  });

  final List<TransferReceipt> receipts;
  final String emptyText;
  final String emptySubtitle;
  final IconData emptyIcon;
  final ValueChanged<TransferReceipt> onPreview;
  final ValueChanged<TransferReceipt> onArchive;
  final ValueChanged<TransferReceipt> onDelete;
  final String archiveLabel;
  final IconData archiveIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (receipts.isEmpty) {
      return EmptyStateWidget(
        message: emptyText,
        subtitle: emptySubtitle,
        icon: emptyIcon,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return _DesktopTable(
            receipts: receipts,
            onPreview: onPreview,
            onArchive: onArchive,
            onDelete: onDelete,
            archiveLabel: archiveLabel,
            archiveIcon: archiveIcon,
          );
        }
        return _MobileList(
          receipts: receipts,
          onPreview: onPreview,
          onArchive: onArchive,
          onDelete: onDelete,
          archiveLabel: archiveLabel,
          archiveIcon: archiveIcon,
        );
      },
    );
  }
}

// ─── قائمة موبايل ─────────────────────────────────────────────────────────────
class _MobileList extends ConsumerWidget {
  const _MobileList({
    required this.receipts,
    required this.onPreview,
    required this.onArchive,
    required this.onDelete,
    required this.archiveLabel,
    required this.archiveIcon,
  });

  final List<TransferReceipt> receipts;
  final ValueChanged<TransferReceipt> onPreview;
  final ValueChanged<TransferReceipt> onArchive;
  final ValueChanged<TransferReceipt> onDelete;
  final String archiveLabel;
  final IconData archiveIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAmounts = ref.watch(showAmountsInListProvider);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
      itemCount: receipts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = receipts[index];
        return _ReceiptCard(
          receipt: r,
          showAmount: showAmounts,
          onPreview: () => onPreview(r),
          onArchive: () => onArchive(r),
          onDelete: () => onDelete(r),
          archiveLabel: archiveLabel,
          archiveIcon: archiveIcon,
        );
      },
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.receipt,
    required this.showAmount,
    required this.onPreview,
    required this.onArchive,
    required this.onDelete,
    required this.archiveLabel,
    required this.archiveIcon,
  });

  final TransferReceipt receipt;
  final bool showAmount;
  final VoidCallback onPreview;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final String archiveLabel;
  final IconData archiveIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onPreview,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── صف الأول: الأسماء والمبلغ ──────────────────────
              Row(
                children: [
                  // رمز الحوالة
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: scheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // المستلم والمرسل
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.receiverName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'من: ${receipt.senderName}',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // المبلغ
                  if (showAmount)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ArabicFormatters.formatAmount(
                            receipt.total,
                            currency: receipt.currency,
                          ),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        Text(
                          'رسوم: ${ArabicFormatters.formatAmount(receipt.fee, currency: receipt.currency)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.45),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // ─── فاصل ───────────────────────────────────────────
              Divider(
                height: 1,
                thickness: 0.5,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              // ─── صف الثاني: رقم الحوالة والتاريخ والإجراءات ─────
              Row(
                children: [
                  // رقم الحوالة
                  _InfoBadge(
                    icon: Icons.tag_rounded,
                    text: ArabicFormatters.toArabicDigits(
                      receipt.transferNumber,
                    ),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  // الوجهة
                  _InfoBadge(
                    icon: Icons.send_rounded,
                    text: receipt.destination,
                    color: Colors.teal,
                  ),
                  const Spacer(),
                  // التاريخ
                  Text(
                    ArabicFormatters.formatDate(receipt.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // قائمة الإجراءات
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'preview') onPreview();
                      if (value == 'archive') onArchive();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('معاينة'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(archiveIcon, size: 18),
                            const SizedBox(width: 8),
                            Text(archiveLabel),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                    tooltip: 'إجراءات',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 140),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── جدول سطح المكتب ──────────────────────────────────────────────────────────
class _DesktopTable extends ConsumerWidget {
  const _DesktopTable({
    required this.receipts,
    required this.onPreview,
    required this.onArchive,
    required this.onDelete,
    required this.archiveLabel,
    required this.archiveIcon,
  });

  final List<TransferReceipt> receipts;
  final ValueChanged<TransferReceipt> onPreview;
  final ValueChanged<TransferReceipt> onArchive;
  final ValueChanged<TransferReceipt> onDelete;
  final String archiveLabel;
  final IconData archiveIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final showAmounts = ref.watch(showAmountsInListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStatePropertyAll(
            scheme.surfaceContainerHighest,
          ),
          headingRowHeight: 48,
          dataRowMaxHeight: 56,
          border: TableBorder.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: 0.5,
            borderRadius: BorderRadius.circular(14),
          ),
          columns: const [
            DataColumn(label: Text('رقم الحوالة')),
            DataColumn(label: Text('المرجع')),
            DataColumn(label: Text('المرسل')),
            DataColumn(label: Text('المستلم')),
            DataColumn(label: Text('الإجمالي')),
            DataColumn(label: Text('الوجهة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('إجراءات')),
          ],
          rows: receipts.map((r) {
            return DataRow(
              onSelectChanged: (_) => onPreview(r),
              cells: [
                DataCell(
                  Text(
                    ArabicFormatters.toArabicDigits(r.transferNumber),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DataCell(
                  Text(ArabicFormatters.toArabicDigits(r.referenceNumber)),
                ),
                DataCell(Text(r.senderName)),
                DataCell(Text(r.receiverName)),
                DataCell(
                  showAmounts
                      ? Text(
                          ArabicFormatters.formatAmount(
                            r.total,
                            currency: r.currency,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        )
                      : const Text('•••'),
                ),
                DataCell(Text(r.destination)),
                DataCell(Text(ArabicFormatters.formatDate(r.createdAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'معاينة',
                        onPressed: () => onPreview(r),
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                      ),
                      IconButton(
                        tooltip: archiveLabel,
                        onPressed: () => onArchive(r),
                        icon: Icon(archiveIcon, size: 18),
                      ),
                      IconButton(
                        tooltip: 'حذف',
                        onPressed: () => onDelete(r),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── مساعد TabBar ─────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

// ─── رسالة الخطأ ──────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'حدث خطأ',
      subtitle: message,
      icon: Icons.error_outline_rounded,
    );
  }
}
