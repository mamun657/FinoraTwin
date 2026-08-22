import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_metric_card.dart';
import '../../core/widgets/finora_skeleton.dart';
import '../../data/repositories/admin_repository.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final repo = ref.read(adminRepositoryProvider);
    final results = await Future.wait([
      repo.fetchStatistics(),
      repo.recentActivity(top: 12),
    ]);
    return _DashboardData(
      stats: results[0] as AdminStats,
      activity: results[1] as List<AdminActivityItem>,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinoraColors.surface,
      appBar: FinoraAppBar(
        title: 'Admin Dashboard',
        subtitle: 'Real-time view of FinoraTwin',
        showBack: true,
        onBack: () => context.go('/dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: FinoraColors.brandPrimary,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: const EdgeInsets.all(FinoraSpacing.lg),
                children: const [
                  FinoraSkeleton(height: 120),
                  SizedBox(height: FinoraSpacing.md),
                  FinoraSkeleton(height: 16),
                  SizedBox(height: FinoraSpacing.md),
                  FinoraSkeleton(height: 80),
                ],
              );
            }
            if (snap.hasError) {
              return _ErrorView(
                message: snap.error.toString(),
                onRetry: _refresh,
              );
            }
            final data = snap.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.sm,
                FinoraSpacing.lg,
                FinoraSpacing.xxl,
              ),
              children: [
                _OverviewHero(stats: data.stats),
                const SizedBox(height: FinoraSpacing.lg),
                _StatGrid(stats: data.stats),
                const SizedBox(height: FinoraSpacing.lg),
                _TrendSection(stats: data.stats),
                const SizedBox(height: FinoraSpacing.lg),
                _RecentActivityCard(items: data.activity),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardData {
  _DashboardData({required this.stats, required this.activity});
  final AdminStats stats;
  final List<AdminActivityItem> activity;
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.stats});
  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: FinoraGradients.midnight,
        borderRadius: BorderRadius.circular(FinoraRadii.xl),
        boxShadow: FinoraShadows.brandGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius:
                      BorderRadius.circular(FinoraRadii.md),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform overview',
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      '${stats.totalUsers} users · ${stats.totalBusinesses} businesses · ${stats.totalTransactions} transactions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          Row(
            children: [
              _HeroMetric(
                label: 'Active',
                value: '${stats.activeUsers}',
                accent: FinoraColors.brandAccent,
              ),
              const SizedBox(width: FinoraSpacing.md),
              _HeroMetric(
                label: 'Admins',
                value: '${stats.adminUsers}',
                accent: FinoraColors.warning,
              ),
              const SizedBox(width: FinoraSpacing.md),
              _HeroMetric(
                label: '7d logins',
                value: '${stats.loginsLast7Days}',
                accent: FinoraColors.brandPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.accent,
  });
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FinoraSpacing.md,
          vertical: FinoraSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(FinoraRadii.md),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.sora(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      FinoraMetricCard(
        label: 'Total users',
        value: '${stats.totalUsers}',
        helper:
            '${stats.usersLast7Days} new in last 7d',
        icon: Icons.group_outlined,
        accentColor: FinoraColors.brandPrimary,
        compact: true,
      ),
      FinoraMetricCard(
        label: 'Active users',
        value: '${stats.activeUsers}',
        helper:
            '${stats.inactiveUsers} inactive',
        icon: Icons.verified_user_outlined,
        accentColor: FinoraColors.positive,
        compact: true,
      ),
      FinoraMetricCard(
        label: 'Businesses',
        value: '${stats.totalBusinesses}',
        helper: 'Across the platform',
        icon: Icons.storefront_outlined,
        accentColor: FinoraColors.brandViolet,
        compact: true,
      ),
      FinoraMetricCard(
        label: 'Transactions',
        value: '${stats.totalTransactions}',
        helper: '${stats.loginsLast30Days} logins / 30d',
        icon: Icons.swap_vert_rounded,
        accentColor: FinoraColors.warning,
        compact: true,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: FinoraSpacing.md,
      mainAxisSpacing: FinoraSpacing.md,
      childAspectRatio: 1.15,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: cards,
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.stats});
  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: FinoraColors.brandPrimary,
              ),
              const SizedBox(width: FinoraSpacing.xs),
              Text('30-day activity', style: FinoraTextStyles.h3),
              const Spacer(),
              _LegendDot(
                color: FinoraColors.brandPrimary,
                label: 'Registrations',
              ),
              const SizedBox(width: FinoraSpacing.sm),
              _LegendDot(
                color: FinoraColors.brandAccent,
                label: 'Logins',
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendPainter(
                registration: stats.registrationSeries,
                logins: stats.loginSeries,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: FinoraTextStyles.caption,
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.registration, required this.logins});

  final List<AdminDailyCount> registration;
  final List<AdminDailyCount> logins;

  @override
  void paint(Canvas canvas, Size size) {
    if (registration.isEmpty && logins.isEmpty) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'No activity yet',
          style: TextStyle(
            color: FinoraColors.textMuted,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          (size.width - tp.width) / 2,
          (size.height - tp.height) / 2,
        ),
      );
      return;
    }
    final maxV = [
      ...registration.map((e) => e.count),
      ...logins.map((e) => e.count),
    ].fold<int>(1, (a, b) => a > b ? a : b);

    _drawSeries(
      canvas: canvas,
      size: size,
      values: registration,
      color: FinoraColors.brandPrimary,
      maxV: maxV,
    );
    _drawSeries(
      canvas: canvas,
      size: size,
      values: logins,
      color: FinoraColors.brandAccent,
      maxV: maxV,
    );
  }

  void _drawSeries({
    required Canvas canvas,
    required Size size,
    required List<AdminDailyCount> values,
    required Color color,
    required int maxV,
  }) {
    if (values.isEmpty) return;
    final n = values.length;
    final dx = n > 1 ? size.width / (n - 1) : 0.0;
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintDot = Paint()..color = color;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final x = dx * i;
      final y = size.height -
          (values[i].count / maxV) * (size.height - 8) -
          4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 2.5, paintDot);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.registration != registration || old.logins != logins;
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.items});
  final List<AdminActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: FinoraColors.brandPrimary,
              ),
              const SizedBox(width: FinoraSpacing.xs),
              Text('Recent activity', style: FinoraTextStyles.h3),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/admin/activity'),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.sm),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FinoraSpacing.md),
              child: Text(
                'No platform activity recorded yet.',
                style: FinoraTextStyles.caption,
              ),
            )
          else
            Column(
              children: [
                for (final a in items.take(8))
                  _ActivityRow(item: a),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});
  final AdminActivityItem item;

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(item.action);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FinoraSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: finoraBadgeBg(tone),
              borderRadius: BorderRadius.circular(FinoraRadii.sm),
            ),
            child: Icon(_iconFor(item.action), size: 16, color: finoraBadgeFg(tone)),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_humanize(item.action)} · ${item.userEmail ?? 'system'}',
                  style: FinoraTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.createdAt != null
                      ? formatRelativeDate(item.createdAt!)
                      : '',
                  style: FinoraTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FinoraBadgeTone _toneFor(String action) {
    if (action.contains('delete')) return FinoraBadgeTone.negative;
    if (action.contains('deactivate')) return FinoraBadgeTone.warning;
    if (action.contains('activate')) return FinoraBadgeTone.positive;
    if (action.contains('create')) return FinoraBadgeTone.brand;
    if (action.contains('update')) return FinoraBadgeTone.info;
    if (action == 'login') return FinoraBadgeTone.positive;
    if (action == 'register') return FinoraBadgeTone.brand;
    return FinoraBadgeTone.neutral;
  }

  IconData _iconFor(String action) {
    if (action.contains('delete')) return Icons.delete_outline_rounded;
    if (action.contains('deactivate')) return Icons.block_rounded;
    if (action.contains('activate')) return Icons.check_circle_outline_rounded;
    if (action.contains('create')) return Icons.add_circle_outline_rounded;
    if (action.contains('update')) return Icons.edit_outlined;
    if (action == 'login') return Icons.login_rounded;
    if (action == 'register') return Icons.person_add_alt_rounded;
    return Icons.bolt_rounded;
  }

  String _humanize(String action) {
    return action
        .split('_')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FinoraSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: FinoraColors.negative,
            ),
            const SizedBox(height: FinoraSpacing.md),
            Text(
              'Could not load dashboard',
              style: FinoraTextStyles.h3,
            ),
            const SizedBox(height: FinoraSpacing.xs),
            Text(
              message,
              style: FinoraTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FinoraSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
