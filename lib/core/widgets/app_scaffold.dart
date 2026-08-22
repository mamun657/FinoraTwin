import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/finora_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.actions,
    this.bottom,
    this.padding = const EdgeInsets.symmetric(
      horizontal: FinoraSpacing.lg,
      vertical: FinoraSpacing.md,
    ),
    this.showBack = false,
    this.onBack,
    this.scroll = true,
    this.refresh,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final EdgeInsets padding;
  final bool showBack;
  final VoidCallback? onBack;
  final bool scroll;
  final Future<void> Function()? refresh;

  @override
  Widget build(BuildContext context) {
    final body = scroll
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: child,
          )
        : Padding(padding: padding, child: child);

    // Always use GoRouter-aware back handling so the back button works
    // regardless of how the screen was pushed (context.push vs go).
    final canPop = GoRouter.of(context).canPop();
    final hasBack = showBack || canPop;
    final backHandler = onBack ?? () => GoRouter.of(context).pop();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: hasBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: backHandler,
              )
            : leading,
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: actions,
        bottom: bottom,
      ),
      body: SafeArea(
        bottom: false,
        child: refresh == null
            ? body
            : RefreshIndicator(onRefresh: refresh!, child: body),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FinoraSpacing.lg),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      side: BorderSide(color: FinoraColors.outline.withValues(alpha: 0.5)),
    );
    final card = Material(
      color: color ?? Theme.of(context).cardColor,
      shape: shape,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    return card;
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FinoraColors.textPrimary,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
