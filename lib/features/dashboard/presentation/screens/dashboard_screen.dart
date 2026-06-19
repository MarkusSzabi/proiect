import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/notifications/notification_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../widgets/fuel_chart_widget.dart';
import '../widgets/maintenance_timeline_widget.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/stat_card.dart';
import '../widgets/vehicle_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    ref.watch(notificationSchedulerProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 156,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D0D14),
                      Color(0xFF151522),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -10,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -35,
                      left: -15,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.chartBlue.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    _greeting(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.displayName ?? 'Driver',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      fontFamily: 'Poppins',
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.08),
                                      ),
                                    ),
                                    child: const Text(
                                      'Manage vehicles, trips and documents',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _TopIconButton(
                              icon: Icons.notifications_none_rounded,
                              badge: true,
                              onTap: () => showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColors.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.outline,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 48,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No notifications yet',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'You\'re all caught up!',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.onSurfaceVariant,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => context.push(RouteNames.profile),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(height: 0.8, color: AppColors.outline),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 18),
                const _OverviewBanner(),
                const SizedBox(height: 22),
                _SectionHeader(title: 'Fuel Overview', onMore: () {}),
                const SizedBox(height: 12),
                const FuelChartWidget(),
                const SizedBox(height: 24),
                _SectionHeader(title: 'This Month', onMore: () {}),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: const [
                    StatCard(
                      icon: Icons.local_gas_station_rounded,
                      iconColor: AppColors.chartTeal,
                      label: 'Fuel Cost',
                      value: '€ 148',
                      trend: '+6%',
                      trendPositive: false,
                    ),
                    StatCard(
                      icon: Icons.route_rounded,
                      iconColor: AppColors.chartBlue,
                      label: 'Distance',
                      value: '1,240 km',
                      trend: '+12%',
                      trendPositive: true,
                    ),
                    StatCard(
                      icon: Icons.build_rounded,
                      iconColor: AppColors.chartOrange,
                      label: 'Maintenance',
                      value: '€ 0',
                      trend: 'All clear',
                      trendPositive: true,
                    ),
                    StatCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.chartPink,
                      label: 'Total Expenses',
                      value: '€ 148',
                      trend: 'vs € 192',
                      trendPositive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                const QuickActionGrid(),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'My Vehicles',
                  onMore: () => context.go(RouteNames.vehicles),
                ),
                const SizedBox(height: 12),
                vehiclesAsync.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return _EmptyVehicles(
                        onAdd: () => context.go(RouteNames.addVehicle),
                      );
                    }

                    return Column(
                      children: [
                        ...vehicles.take(2).map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: VehicleCard(
                                  vehicle: v,
                                  onTap: () => context.go(
                                    '${RouteNames.vehicles}/${v.id}',
                                  ),
                                ),
                              ),
                            ),
                        if (vehicles.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '+${vehicles.length - 2} more vehicles',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const _LoadingCards(),
                  error: (e, _) => const _ErrorCard(),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Upcoming Maintenance',
                  onMore: () => context.go(RouteNames.maintenance),
                ),
                const SizedBox(height: 12),
                const MaintenanceTimelineWidget(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.chartBlue.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primaryLight,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your dashboard gives you a quick view of fuel, maintenance, trips and vehicles.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onMore,
  });

  final String title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            letterSpacing: -0.2,
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline,
                width: 0.8,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
          if (badge)
            Positioned(
              right: 9,
              top: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyVehicles extends StatelessWidget {
  const _EmptyVehicles({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outline,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: AppColors.primaryLight,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No vehicles added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your first vehicle to start tracking',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Add Vehicle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          height: 130,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 22,
          ),
          SizedBox(width: 12),
          Text(
            'Failed to load vehicles',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.danger,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
