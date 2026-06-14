import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import 'active_trip_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsStreamProvider);
    final tripState = ref.watch(tripNotifierProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Trips',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: AppColors.outline),
        ),
      ),
      body: Column(
        children: [
          // ── Banner cursă activă ───────────────────────
          if (tripState.isTracking)
            _ActiveTripBanner(
              state: tripState,
              onTap: () => _openActiveTrip(context),
            ),

          // ── Lista curse ───────────────────────────────
          Expanded(
            child: activeVehicle == null
                ? const _NoVehiclePrompt()
                : trips.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                    error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: const TextStyle(
                                color: AppColors.onSurfaceVariant))),
                    data: (list) {
                      final finished = list.where((t) => !t.isActive).toList();
                      if (finished.isEmpty) {
                        return _EmptyState(
                          onStart: () => _openActiveTrip(context),
                        );
                      }
                      return _TripsList(trips: finished, ref: ref);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: activeVehicle == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openActiveTrip(context),
              icon: Icon(
                tripState.isTracking
                    ? Icons.gps_fixed
                    : Icons.play_arrow_rounded,
              ),
              label: Text(tripState.isTracking ? 'Live Trip' : 'New Trip'),
              backgroundColor:
                  tripState.isTracking ? AppColors.danger : AppColors.primary,
              foregroundColor: Colors.white,
            ),
    );
  }

  // ── Deschide ActiveTripScreen o singură dată ──────────
  static void _openActiveTrip(BuildContext context) {
    // Verifică dacă ActiveTripScreen e deja în stack
    // ca să evităm loop-ul infinit
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ActiveTripScreen(),
        // fullscreenDialog previne dubla navigare din ShellRoute
        fullscreenDialog: true,
      ),
    );
  }
}

class _ActiveTripBanner extends StatelessWidget {
  const _ActiveTripBanner({required this.state, required this.onTap});
  final ActiveTripState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          border: Border(
              bottom: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.3), width: 0.8)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.gps_fixed, color: AppColors.danger, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip in progress',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '${state.distanceDisplay} · ${state.elapsedDisplay}',
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _TripsList extends StatelessWidget {
  const _TripsList({required this.trips, required this.ref});
  final List<Trip> trips;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Trip>>{};
    for (final t in trips) {
      final key = DateFormat('MMMM yyyy').format(t.startTime);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: months.length,
      itemBuilder: (_, i) {
        final month = months[i];
        final monthTrips = grouped[month]!;
        final totalKm = monthTrips.fold(0.0, (sum, t) => sum + t.distanceKm);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '${totalKm.toStringAsFixed(1)} km total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ...monthTrips.map((t) => _TripTile(
                  trip: t,
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed) {
                      await ref
                          .read(tripNotifierProvider.notifier)
                          .deleteTrip(t.id);
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Delete Trip',
                style: TextStyle(
                    color: AppColors.onSurface, fontFamily: 'Poppins')),
            content: const Text('Are you sure you want to delete this trip?',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontFamily: 'Poppins')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip, required this.onDelete});
  final Trip trip;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMM').format(trip.startTime);
    final timeStr = DateFormat('HH:mm').format(trip.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.route_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.distanceDisplay,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '$dateStr · $timeStr',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer_outlined,
                        size: 11, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      trip.durationDisplay,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.onSurfaceVariant, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.route_outlined,
                size: 36, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 16),
          const Text(
            'No trips yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to start your first trip',
            style: TextStyle(
                color: AppColors.onSurfaceVariant, fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Start First Trip',
                style: TextStyle(
                  fontSize: 14,
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

class _NoVehiclePrompt extends StatelessWidget {
  const _NoVehiclePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_outlined,
                size: 36, color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'No vehicle selected',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a vehicle first to track trips',
            style: TextStyle(
                color: AppColors.onSurfaceVariant, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
