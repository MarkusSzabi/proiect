import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _navItems = [
    _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: RouteNames.dashboard),
    _NavItem(
        icon: Icons.route_outlined,
        activeIcon: Icons.route,
        label: 'Trips',
        route: RouteNames.trips),
    _NavItem(
        icon: Icons.build_outlined,
        activeIcon: Icons.build,
        label: 'Service',
        route: RouteNames.maintenance),
    _NavItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: 'Docs',
        route: RouteNames.documents),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Stats',
        route: RouteNames.statistics),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = selectedIndex == i;
                return GestureDetector(
                  onTap: () => context.go(item.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.onSurfaceVariant,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
