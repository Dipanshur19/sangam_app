import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme.dart';
import '../../../core/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _counterCtrl;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  String _greeting(bool hi) {
    final hour = DateTime.now().hour;
    if (hour < 12) return tr('Good morning', 'सुप्रभात', hi);
    if (hour < 17) return tr('Good afternoon', 'नमस्कार', hi);
    return tr('Good evening', 'शुभ संध्या', hi);
  }

  @override
  Widget build(BuildContext context) {
    final hi = ref.watch(languageProvider);
    final totalsAsync = ref.watch(todayTotalsProvider);
    final overdueAsync = ref.watch(overdueCustomersProvider);
    final txnsAsync = ref.watch(transactionsStreamProvider);
    final store = ref.watch(storeProfileProvider);
    final canEdit = ref.watch(currentUserProvider)?.canEdit ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(hi),
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.saffron,
                            ),
                          ),
                          Text(
                            store.name.isEmpty
                                ? tr('My Store', 'मेरी दुकान', hi)
                                : store.name,
                            style: AppTextStyles.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _IconBtn(
                      Icons.inbox_outlined,
                      () => context.push('/sms-queue'),
                      badge: ref
                          .watch(smsQueueProvider)
                          .where((e) => e.status == 'pending')
                          .length,
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      Icons.settings_outlined,
                      () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                totalsAsync.when(
                  loading: () => const _HeroCardSkeleton(),
                  error: (e, _) => const SizedBox(),
                  data: (totals) => _HeroCard3D(
                    totals: totals,
                    tiltX: 0,
                    tiltY: 0,
                    ctrl: _counterCtrl,
                    hi: hi,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 700.ms,
                        curve: Curves.easeOut,
                      ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: totalsAsync.when(
                          loading: () => const _StatSkeleton(),
                          error: (_, __) => const SizedBox(),
                          data: (t) => _StatCard(
                            label: tr('Udhar Given', 'उधार दिया', hi),
                            value: t.creditOut,
                            color: AppColors.udhar,
                            bg: AppColors.udharBg,
                            icon: Icons.credit_card_outlined,
                          )
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: overdueAsync.when(
                          loading: () => const _StatSkeleton(),
                          error: (_, __) => const SizedBox(),
                          data: (o) => _StatCard(
                            label: tr('Outstanding', 'बकाया', hi),
                            value: o.fold(0.0, (s, x) => s + x.balance),
                            color: AppColors.cash,
                            bg: AppColors.cashBg,
                            icon: Icons.trending_up_rounded,
                            subtitle: '${o.length} ${tr('customers', 'ग्राहक', hi)}',
                            onTap: () => context.push('/customers'),
                          )
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.2, end: 0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                totalsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (t) => t.upiTotal > 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _UpiChart(totals: t)
                              .animate(delay: 400.ms)
                              .fadeIn(duration: 500.ms),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(height: 16),
                overdueAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (overdue) {
                    if (overdue.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.warningBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 13,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tr('Overdue', 'बकाया (समय पार)', hi),
                                style: AppTextStyles.h4,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => context.push('/customers'),
                                child: Text(
                                  tr('See all →', 'सभी देखें →', hi),
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.saffron,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...overdue.take(3).toList().asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: _OverdueCard(
                                  entry: e.value,
                                  onTap: () => context.push('/customer/${e.value.customerId}'),
                                )
                                    .animate(
                                      delay: Duration(
                                        milliseconds: 450 + e.key * 80,
                                      ),
                                    )
                                    .fadeIn(duration: 400.ms)
                                    .slideX(begin: -0.15, end: 0),
                              ),
                            ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Text(tr('Recent', 'हाल के', hi), style: AppTextStyles.h4),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/report'),
                        child: Text(
                          tr('Full report →', 'पूरी रिपोर्ट →', hi),
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                txnsAsync.when(
                  loading: () => const _TxnListSkeleton(),
                  error: (e, _) => const SizedBox(),
                  data: (txns) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: txns.isEmpty
                        ? _GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 36,
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 40,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    tr('No transactions yet', 'अभी कोई लेन-देन नहीं', hi),
                                    style: AppTextStyles.bodyMd,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    canEdit
                                        ? tr(
                                            'Tap the + button to record your first sale or udhar.',
                                            'अपनी पहली बिक्री या उधार दर्ज करने के लिए + दबाएँ।',
                                            hi,
                                          )
                                        : tr(
                                            'Transactions added by your team will appear here.',
                                            'आपकी टीम द्वारा जोड़े गए लेन-देन यहाँ दिखेंगे।',
                                            hi,
                                          ),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption,
                                  ),
                                  if (canEdit) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => context.push('/add'),
                                      icon: const Icon(Icons.add_rounded, size: 18),
                                      label: Text(
                                        tr('Add transaction', 'लेन-देन जोड़ें', hi),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : _GlassCard(
                            child: Column(
                              children: txns.take(5).toList().asMap().entries.map((e) {
                                final isLast = e.key == txns.take(5).length - 1;
                                return _TxnRow(txn: e.value, isLast: isLast);
                              }).toList(),
                            ),
                          ).animate(delay: 520.ms).fadeIn(duration: 450.ms),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/add'),
              backgroundColor: AppColors.saffron,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                tr('Add', 'जोड़ें', hi),
                style: AppTextStyles.btn.copyWith(color: Colors.white),
              ),
            ).animate().scale(delay: 650.ms, duration: 400.ms)
          : null,
      bottomNavigationBar: const SangamBottomNav(currentIndex: 0),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  const _IconBtn(this.icon, this.onTap, {this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.sm,
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Icon(icon, size: 20, color: AppColors.text2),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.md,
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: child,
    );
  }
}

class _HeroCardSkeleton extends StatelessWidget {
  const _HeroCardSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(height: 170),
      );
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 110);
}

class _TxnListSkeleton extends StatelessWidget {
  const _TxnListSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(height: 180),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final Color bg;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.text4,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${value.toStringAsFixed(0)}',
              style: AppTextStyles.h3.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(color: AppColors.text4),
              ),
            ],
          ],
        ),
      ),
    );

    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }
}

class _HeroCard3D extends StatelessWidget {
  final dynamic totals;
  final double tiltX, tiltY;
  final AnimationController ctrl;
  final bool hi;

  const _HeroCard3D({
    required this.totals,
    required this.tiltX,
    required this.tiltY,
    required this.ctrl,
    required this.hi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(tiltX * 0.4)
          ..rotateY(tiltY * 0.4),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.saffron,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: AppShadows.saffron,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tr('Total collected today', 'आज कुल जमा', hi),
                          style: AppTextStyles.label.copyWith(color: Colors.white70),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'LIVE',
                            style: AppTextStyles.labelCaps.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _AnimatedCounter(
                      value: totals.totalIn,
                      style: AppTextStyles.amount.copyWith(color: Colors.white),
                      ctrl: ctrl,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _WhiteChip('Paytm', totals.paytm, const Color(0xFF6B8EFF)),
                        _WhiteChip('GPay', totals.gpay, const Color(0xFF6EE7B7)),
                        _WhiteChip('PhonePe', totals.phonePe, const Color(0xFFDDA0DD)),
                        _WhiteChip('Cash', totals.cash, const Color(0xFFFFD700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color dot;
  const _WhiteChip(this.label, this.amount, this.dot);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '$label ₹${amount.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle style;
  final AnimationController ctrl;

  const _AnimatedCounter({
    required this.value,
    required this.style,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final current =
              (value * CurvedAnimation(parent: ctrl, curve: Curves.easeOut).value)
                  .toInt();
          return Text(
            '₹${current.toString().replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{2})+(?!\d))'), (m) => '${m[1]},')}',
            style: style,
          );
        },
      );
}

class _UpiChart extends StatelessWidget {
  final dynamic totals;
  const _UpiChart({required this.totals});

  @override
  Widget build(BuildContext context) {
    final sections = [
      PieChartSectionData(value: totals.paytm, color: AppColors.paytm, radius: 22, title: ''),
      PieChartSectionData(value: totals.gpay, color: AppColors.gpay, radius: 22, title: ''),
      PieChartSectionData(value: totals.phonePe, color: AppColors.phonePe, radius: 22, title: ''),
      PieChartSectionData(value: totals.cash, color: AppColors.cash, radius: 22, title: ''),
    ].where((s) => s.value > 0).toList();

    if (sections.isEmpty) return const SizedBox();

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 28,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UPI breakdown', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _ChartLegend('Paytm', totals.paytm, AppColors.paytm),
                  _ChartLegend('GPay', totals.gpay, AppColors.gpay),
                  _ChartLegend('PhonePe', totals.phonePe, AppColors.phonePe),
                  _ChartLegend('Cash', totals.cash, AppColors.cash),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ChartLegend(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption),
            const Spacer(),
            Text(
              '₹${value.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text1,
              ),
            ),
          ],
        ),
      );
}

class _OverdueCard extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onTap;
  const _OverdueCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.udharBg, width: 1.5),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.udharBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.customerName[0],
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.udhar,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.customerName, style: AppTextStyles.bodyMd),
                    Text(
                      entry.daysOverdue > 0 ? '${entry.daysOverdue}d overdue' : 'Due today',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${entry.balance.toStringAsFixed(0)}',
                style: AppTextStyles.amountSm.copyWith(color: AppColors.udhar),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.text4),
            ],
          ),
        ),
      );
}

class _TxnRow extends StatelessWidget {
  final dynamic txn;
  final bool isLast;
  const _TxnRow({required this.txn, required this.isLast});

  static const _colors = {
    'upi_paytm': AppColors.paytm,
    'upi_gpay': AppColors.gpay,
    'upi_phonePe': AppColors.phonePe,
    'cash': AppColors.cash,
    'credit': AppColors.udhar,
  };

  static const _labels = {
    'upi_paytm': 'Paytm',
    'upi_gpay': 'GPay',
    'upi_phonePe': 'PhonePe',
    'cash': 'Cash',
    'credit': 'Udhar',
  };

  @override
  Widget build(BuildContext context) {
    final typeKey = txn.type?.firestoreKey ?? 'cash';
    final color = _colors[typeKey] ?? AppColors.cash;
    final label = _labels[typeKey] ?? 'Cash';
    final isIn = txn.direction?.toString().contains('incoming') ?? true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.customerName ?? 'Customer', style: AppTextStyles.bodyMd),
                    const SizedBox(height: 2),
                    Text(label, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Text(
                '₹${txn.amount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: isIn ? AppColors.success : AppColors.text1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 0, indent: 66),
      ],
    );
  }
}
