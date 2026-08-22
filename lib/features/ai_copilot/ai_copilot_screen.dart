import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/error_handler.dart';
import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/ai_repository.dart';
import 'ai_markdown_view.dart';

final _messagesProvider = StateProvider.autoDispose<List<AiChatMessage>>(
  (_) => const [],
);

final _sendingProvider = StateProvider.autoDispose<bool>((_) => false);

class AiCopilotScreen extends ConsumerStatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  ConsumerState<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends ConsumerState<AiCopilotScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _suggestions = <String>[
    'Summarize my financial health this month',
    'Where am I overspending?',
    'Can I afford a \$50,000 loan over 12 months?',
    "Forecast next month's revenue",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final business = ref.read(activeBusinessControllerProvider);
    if (!business.hasBusiness) {
      showErrorSnackBar(context, 'Set up your business first.');
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = AiChatMessage(role: 'user', content: trimmed);
    final current = [...ref.read(_messagesProvider), user];
    ref.read(_messagesProvider.notifier).state = current;
    _controller.clear();
    _scrollToEnd();
    ref.read(_sendingProvider.notifier).state = true;

    try {
      final repo = ref.read(aiRepositoryProvider);
      final response = await repo.chat(messages: current);
      final reply = AiChatMessage(role: 'assistant', content: response.message);
      ref.read(_messagesProvider.notifier).state = [...current, reply];
      ref.read(aiConversationVersionProvider.notifier).state++;
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    } finally {
      if (mounted) ref.read(_sendingProvider.notifier).state = false;
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: FinoraMotion.standard,
      );
    });
  }

  void _clearChat() {
    ref.read(_messagesProvider.notifier).state = const [];
    ref.read(aiConversationVersionProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final sending = ref.watch(_sendingProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: FinoraAppBar(
        title: 'AI copilot',
        subtitle: 'Powered by your live data',
        showBack: true,
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear chat',
              icon: const Icon(Icons.delete_sweep_outlined, size: 22),
              onPressed: _clearChat,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: messages.isEmpty
                    ? _EmptyState(onSuggestion: _send)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          FinoraSpacing.lg,
                          FinoraSpacing.md,
                          FinoraSpacing.lg,
                          FinoraSpacing.md,
                        ),
                        itemCount: messages.length + (sending ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i >= messages.length) {
                            return const _ThinkingBubble();
                          }
                          return _MessageBubble(message: messages[i]);
                        },
                      ),
              ),
            ),
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              sending: sending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FinoraSpacing.lg,
        FinoraSpacing.md,
        FinoraSpacing.lg,
        FinoraSpacing.lg,
      ),
      children: [
        const SizedBox(height: FinoraSpacing.lg),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: FinoraGradients.brand,
              shape: BoxShape.circle,
              boxShadow: FinoraShadows.brandGlow,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: FinoraSpacing.lg),
        const Text(
          'Your FinoraTwin copilot',
          textAlign: TextAlign.center,
          style: FinoraTextStyles.title,
        ),
        const SizedBox(height: FinoraSpacing.xs),
        const Text(
          'Ask about your cash flow, expenses, loan readiness, or forecasts. '
          'Answers use your live business data.',
          textAlign: TextAlign.center,
          style: FinoraTextStyles.body,
        ),
        const SizedBox(height: FinoraSpacing.xl),
        const FinoraSectionHeader(
          title: 'Try one of these',
          padding: EdgeInsets.symmetric(horizontal: 0),
        ),
        const SizedBox(height: FinoraSpacing.sm),
        ..._AiCopilotScreenState._suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: FinoraSpacing.xs),
            child: FinoraFinancialCard(
              tone: FinoraCardTone.brand,
              padding: const EdgeInsets.symmetric(
                horizontal: FinoraSpacing.md,
                vertical: FinoraSpacing.sm,
              ),
              onTap: () => onSuggestion(s),
              child: Row(
                children: [
                  const FinoraIconChip(
                    icon: Icons.bolt_rounded,
                    tone: FinoraBadgeTone.brand,
                    size: 36,
                  ),
                  const SizedBox(width: FinoraSpacing.sm),
                  Expanded(child: Text(s, style: FinoraTextStyles.body)),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: FinoraColors.brandPrimaryDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AiChatMessage message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.85;
    final userBg = BoxDecoration(
      gradient: FinoraGradients.brand,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(22),
        topRight: const Radius.circular(22),
        bottomLeft: const Radius.circular(22),
        bottomRight: Radius.circular(_isUser ? 4 : 22),
      ),
      boxShadow: FinoraShadows.sm,
    );
    final assistantBg = BoxDecoration(
      color: FinoraColors.surfaceAlt,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      border: Border.all(color: FinoraColors.outline),
      boxShadow: FinoraShadows.xs,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: _isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (_isUser)
            const Padding(
              padding: EdgeInsets.only(bottom: 4, right: 4),
              child: Text(
                'You',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: FinoraColors.brandPrimaryDark,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 4, left: 4),
              child: Text(
                'FinoraTwin',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: FinoraColors.textSecondary,
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _isUser ? 14 : FinoraSpacing.md,
                vertical: _isUser ? 12 : FinoraSpacing.md,
              ),
              decoration: _isUser ? userBg : assistantBg,
              child: _isUser
                  ? Text(
                      message.content,
                      style: FinoraTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : AiMarkdownView(content: message.content, isUser: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4, left: 4),
            child: Text(
              'FinoraTwin',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: FinoraColors.textSecondary,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.55,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: FinoraColors.brandPrimarySoft,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(22),
                ),
                border: Border.all(
                  color: FinoraColors.brandPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final t = (_controller.value + i * 0.18) % 1.0;
                          final delta = (t - 0.5).abs() * 2;
                          final scale = 0.6 + 0.4 * (1 - delta).clamp(0.0, 1.0);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: FinoraColors.brandPrimaryDark
                                      .withValues(alpha: 0.55 + 0.45 * scale),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Thinking...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FinoraColors.brandPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends ConsumerStatefulWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  ConsumerState<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<_InputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.sending;

    final borderColor = widget.focusNode.hasFocus
        ? FinoraColors.brandPrimary.withValues(alpha: 0.55)
        : FinoraColors.outline;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        FinoraSpacing.md,
        FinoraSpacing.sm,
        FinoraSpacing.md,
        FinoraSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: FinoraColors.surfaceAlt,
        border: Border(
          top: BorderSide(color: FinoraColors.outline.withValues(alpha: 0.6)),
        ),
        boxShadow: FinoraShadows.sm,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: FinoraColors.surface,
                  borderRadius: BorderRadius.circular(FinoraRadii.xl),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: FinoraSpacing.sm,
                  vertical: FinoraSpacing.xs,
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: FinoraTextStyles.body,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintText: 'Ask anything about your business...',
                    hintStyle: TextStyle(
                      color: FinoraColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: FinoraSpacing.xs),
            _SendButton(
              canSend: canSend,
              sending: widget.sending,
              onTap: canSend
                  ? () => widget.onSend(widget.controller.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.canSend,
    required this.sending,
    required this.onTap,
  });

  final bool canSend;
  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.xl),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: canSend ? FinoraGradients.brand : null,
            color: canSend ? null : FinoraColors.outlineSoft,
            borderRadius: BorderRadius.circular(FinoraRadii.xl),
            boxShadow: canSend ? FinoraShadows.brandGlow : null,
          ),
          alignment: Alignment.center,
          child: sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  size: 22,
                  color: canSend ? Colors.white : FinoraColors.textMuted,
                ),
        ),
      ),
    );
  }
}
