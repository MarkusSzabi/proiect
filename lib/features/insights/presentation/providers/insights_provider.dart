import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/trip/presentation/providers/trip_provider.dart';
import '../../../../features/vehicle/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/insight_data.dart';

final statisticsProvider = FutureProvider<StatsSummary>((ref) async {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) {
    return const StatsSummary(
      totalKm: 0,
      totalTrips: 0,
      avgKmPerTrip: 0,
      monthlyStats: [],
    );
  }

  final trips =
      await ref.read(getTripsUseCaseProvider).execute(activeVehicle.id).first;

  final finished = trips.where((t) => !t.isActive && t.distanceKm > 0).toList();

  final now = DateTime.now();
  final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
  final recentTrips =
      finished.where((t) => t.startTime.isAfter(threeMonthsAgo)).toList();

  final Map<String, MonthlyStats> statsMap = {};

  for (int i = 2; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);
    final key = '${date.year}-${date.month}';
    statsMap[key] = MonthlyStats(
      month: date.month,
      year: date.year,
      totalKm: 0,
      tripCount: 0,
    );
  }

  for (final trip in recentTrips) {
    final key = '${trip.startTime.year}-${trip.startTime.month}';
    if (statsMap.containsKey(key)) {
      final existing = statsMap[key]!;
      statsMap[key] = MonthlyStats(
        month: existing.month,
        year: existing.year,
        totalKm: existing.totalKm + trip.distanceKm,
        tripCount: existing.tripCount + 1,
      );
    }
  }

  final monthlyList = statsMap.values.toList()
    ..sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

  final totalKm = finished.fold(0.0, (sum, t) => sum + t.distanceKm);
  final totalTrips = finished.length;
  final avgKmPerTrip = totalTrips > 0 ? totalKm / totalTrips : 0.0;

  return StatsSummary(
    totalKm: totalKm,
    totalTrips: totalTrips,
    avgKmPerTrip: avgKmPerTrip,
    monthlyStats: monthlyList,
  );
});
