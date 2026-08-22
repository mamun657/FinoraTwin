import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/finora_theme.dart';

class FinoraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FinoraAppBar({
    super.key,
    this.title = '',
    this.subtitle,
    this.leading,
    this.actions,
    this.bottom,
    this.showBack = false,
    this.onBack,
    this.transparent = false,
    this.center = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBack;
  final VoidCallback? onBack;
  final bool transparent;
  final bool center;

  @override
  Size get preferredSize {
    final hasContent = title.isNotEmpty || subtitle != null;
    final extra = subtitle != null ? 6.0 : 0.0;
    final bottomH = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(
      (hasContent ? 56 + extra : kToolbarHeight) + bottomH,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = showBack || GoRouter.of(context).canPop();
    final handler = onBack ?? () => GoRouter.of(context).pop();

    final leadingWidget =
        leading ??
        (canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                onPressed: handler,
                splashRadius: 22,
              )
            : null);

    final titleColumn = title.isEmpty
        ? null
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FinoraTextStyles.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: FinoraTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );

    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: center,
      leading: leadingWidget,
      automaticallyImplyLeading: false,
      title: titleColumn,
      actions: actions == null
          ? null
          : [...actions!, const SizedBox(width: FinoraSpacing.xs)],
      bottom: bottom,
      iconTheme: IconThemeData(color: FinoraColors.textPrimary),
      titleTextStyle: FinoraTextStyles.title,
      titleSpacing: titleColumn == null ? 0 : FinoraSpacing.md,
    );
  }
}
