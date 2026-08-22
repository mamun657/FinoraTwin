import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = _groupsFor(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: FinoraAppBar(title: 'Financial Tools', showBack: true),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.xs,
                FinoraSpacing.lg,
                FinoraSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == groups.length - 1
                            ? 0
                            : FinoraSpacing.lg,
                        top: index == 0 ? 0 : 0,
                      ),
                      child: _GroupSection(group: group),
                    );
                  },
                  childCount: groups.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


List<_ExploreGroup> _groupsFor(BuildContext context) {
    return const [
      _ExploreGroup(
        title: 'Financial Health',
        items: [
          _ExploreItem(
            icon: Icons.favorite_rounded,
            tone: FinoraBadgeTone.positive,
            title: 'Financial Health',
            subtitle: 'Understand your overall financial position.',
            route: '/financial-health',
          ),
          _ExploreItem(
            icon: Icons.water_drop_outlined,
            tone: FinoraBadgeTone.warning,
            title: 'Cash Pressure',
            subtitle: 'See how long your cash can sustain the business.',
            route: '/cash-pressure',
          ),
          _ExploreItem(
            icon: Icons.search_rounded,
            tone: FinoraBadgeTone.negative,
            title: 'Leak Detector',
            subtitle: 'Find unusual or rising expenses.',
            route: '/leak-detector',
          ),
        ],
      ),
      _ExploreGroup(
        title: 'Business Twin',
        items: [
          _ExploreItem(
            icon: Icons.psychology_outlined,
            tone: FinoraBadgeTone.brand,
            title: 'Scenarios',
            subtitle: 'Simulate financial decisions before you commit.',
            route: '/scenarios',
          ),
          _ExploreItem(
            icon: Icons.task_alt_rounded,
            tone: FinoraBadgeTone.info,
            title: 'Action Plan',
            subtitle: 'See recommended next steps for your business.',
            route: '/action-plan',
          ),
        ],
      ),
      _ExploreGroup(
        title: 'Planning',
        items: [
          _ExploreItem(
            icon: Icons.flag_outlined,
            tone: FinoraBadgeTone.brand,
            title: 'Goals',
            subtitle: 'Track important financial targets.',
            route: '/goals',
          ),
          _ExploreItem(
            icon: Icons.account_balance_outlined,
            tone: FinoraBadgeTone.positive,
            title: 'Funding Readiness',
            subtitle: 'See how prepared your business is for funding.',
            route: '/funding',
          ),
        ],
      ),
      _ExploreGroup(
        title: 'AI',
        items: [
          _ExploreItem(
            icon: Icons.auto_awesome_outlined,
            tone: FinoraBadgeTone.brand,
            title: 'AI Advisor',
            subtitle: 'Chat with your AI financial advisor.',
            route: '/ai-copilot',
          ),
        ],
      ),
      _ExploreGroup(
        title: 'Data',
        items: [
          _ExploreItem(
            icon: Icons.verified_outlined,
            tone: FinoraBadgeTone.info,
            title: 'Data Quality',
            subtitle: 'Review the health of your transaction data.',
            route: '/data-quality',
          ),
        ],
      ),
    ];
  }
}
class _ExploreGroup {
  const _ExploreGroup({required this.title, required this.items});

  final String title;
  final List<_ExploreItem> items;
}

class _ExploreItem {
  const _ExploreItem({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final FinoraBadgeTone tone;
  final String title;
  final String subtitle;
  final String route;
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group});

  final _ExploreGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: FinoraSpacing.xxs,
            bottom: FinoraSpacing.sm,
          ),
          child: Text(
            group.title.toUpperCase(),
            style: FinoraTextStyles.overline.copyWith(
              color: FinoraColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        FinoraFinancialCard(
          tone: FinoraCardTone.neutral,
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.xs,
            vertical: FinoraSpacing.xxs,
          ),
          child: Column(
            children: [
              for (var i = 0; i < group.items.length; i++)
                Column(
                  children: [
                    _ExploreRow(item: group.items[i]),
                    if (i != group.items.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: FinoraSpacing.md,
                        ),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: FinoraColors.outline,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExploreRow extends StatelessWidget {
  const _ExploreRow({required this.item});

  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    final bg = finoraBadgeBg(item.tone);
    final fg = finoraBadgeFg(item.tone);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.route == '/ai-copilot') {
            context.go(item.route);
          } else {
            context.push(item.route);
          }
        },
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.md,
            vertical: FinoraSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(FinoraRadii.sm),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: fg, size: 22),
              ),
              const SizedBox(width: FinoraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: FinoraTextStyles.h4,
                    ),
                    const SizedBox(height: FinoraSpacing.xxs),
                    Text(
                      item.subtitle,
                      style: FinoraTextStyles.body.copyWith(
                        color: FinoraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: FinoraColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
