import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../providers/assistant_provider.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  // Suggested questions
  static const _suggestions = [
    '🔧 When should I change my oil?',
    '📋 What documents do I need for ITP?',
    '⚠️ What does the engine warning light mean?',
    '⛽ How can I improve fuel efficiency?',
    '🛡️ What is RCA insurance?',
    '🛣️ Do I need Rovinieta on highways?',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _hasText = false);
    ref.read(assistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(assistantProvider);

    // Auto-scroll quando arriva un nuovo messaggio
    ref.listen<ChatState>(assistantProvider, (_, next) {
      if (!next.isLoading) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(chatState),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(chatState),
          ),
          if (chatState.error != null) _buildErrorBanner(chatState.error!),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState chatState) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.onSurface, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Always here to help',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (chatState.messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.onSurfaceVariant, size: 22),
            onPressed: () => _showClearDialog(),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.8),
        child: Container(height: 0.8, color: AppColors.outline),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // AI avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Smart Driver Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your vehicles,\ndocuments, maintenance, or driving.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Suggestions
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggested questions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceMuted,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map((s) => _SuggestionChip(
                      label: s,
                      onTap: () {
                        _controller.text = s.substring(2).trim();
                        setState(() => _hasText = true);
                        _sendMessage();
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isUser = message.role == MessageRole.user;

        return _MessageBubble(
          message: message,
          isUser: isUser,
          showAvatar: !isUser &&
              (index == 0 ||
                  chatState.messages[index - 1].role == MessageRole.user),
        );
      },
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(top: BorderSide(color: AppColors.outline, width: 0.8)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline, width: 0.8),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  fontFamily: 'Poppins',
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask anything about your car...',
                  hintStyle: TextStyle(
                    color: AppColors.onSurfaceMuted,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _hasText ? AppColors.primaryGradient : null,
              color: _hasText ? null : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: _hasText
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: _hasText ? _sendMessage : null,
              icon: Icon(
                Icons.send_rounded,
                color: _hasText ? Colors.white : AppColors.onSurfaceMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear conversation',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear the entire conversation?',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              ref.read(assistantProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            child:
                const Text('Clear', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isUser,
    this.showAvatar = false,
  });

  final ChatMessage message;
  final bool isUser;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser) ...[
            if (showAvatar)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 14),
              )
            else
              const SizedBox(width: 30),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.outline, width: 0.8),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: message.isLoading
                  ? const _TypingIndicator()
                  : Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.onSurface,
                        fontFamily: 'Poppins',
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),

          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Typing indicator ───────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final delay = i * 0.33;
              final t = ((_controller.value - delay) % 1.0 + 1.0) % 1.0;
              final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7 * scale,
                height: 7 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ── Suggestion chip ────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineLight, width: 0.8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
