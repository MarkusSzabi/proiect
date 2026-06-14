import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  static const _actions = [
    _QuickAction(
      icon: Icons.folder_open_rounded,
      label: 'Documents',
      route: RouteNames.documents,
      color: Color(0xFF00D4AA),
      gradientEnd: Color(0xFF40C4FF),
    ),
    _QuickAction(
      icon: Icons.build_rounded,
      label: 'Maintenance',
      route: RouteNames.maintenance,
      color: Color(0xFF40C4FF),
      gradientEnd: Color(0xFF6C63FF),
    ),
    _QuickAction(
      icon: Icons.bar_chart_rounded,
      label: 'Statistics',
      route: RouteNames.statistics,
      color: Color(0xFFFF6B9D),
      gradientEnd: Color(0xFFFF8C42),
    ),
    _QuickAction(
      icon: Icons.auto_awesome_rounded,
      label: 'AI\nAssistant',
      route: RouteNames.assistant,
      color: Color(0xFF6C63FF),
      gradientEnd: Color(0xFF9D97FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: _actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.gradientEnd,
  });
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final Color gradientEnd;
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        context.go(action.route);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      action.color.withValues(alpha: 0.18),
                      action.gradientEnd.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: action.color.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: Icon(action.icon, color: action.color, size: 19),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontFamily: 'Poppins',
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
