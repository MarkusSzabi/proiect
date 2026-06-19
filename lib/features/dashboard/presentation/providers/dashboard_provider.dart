import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../maintenance/presentation/providers/maintenance_provider.dart';

class DashboardStats {
  const DashboardStats({
    this.totalKm = 0,
    this.tripsThisMonth = 0,
    this.kmThisMonth = 0,
    this.drivingHoursThisMonth = 0,
    this.maintenanceAlertsCount = 0,
    this.documentsExpiringCount = 0,
  });

  final double totalKm;
  final int tripsThisMonth;
  final double kmThisMonth;
  final double drivingHoursThisMonth;
  final int maintenanceAlertsCount;
  final int documentsExpiringCount;
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return const DashboardStats();

  final totalKm = activeVehicle.currentMileageKm;

  final tripsAsync = ref.watch(tripsStreamProvider);
  final trips = tripsAsync.valueOrNull ?? [];
  final now = DateTime.now();

  final thisMonthTrips = trips
      .where((t) =>
          !t.isActive &&
          t.endTime != null &&
          t.startTime.year == now.year &&
          t.startTime.month == now.month)
      .toList();

  final tripsThisMonth = thisMonthTrips.length;
  final kmThisMonth = thisMonthTrips.fold(0.0, (sum, t) => sum + t.distanceKm);

  final drivingHoursThisMonth = thisMonthTrips.fold(0.0, (sum, t) {
    if (t.endTime == null) return sum;
    return sum + t.endTime!.difference(t.startTime).inMinutes / 60.0;
  });

  final maintenanceAsync = ref.watch(maintenanceRecordsProvider);
  final maintenance = maintenanceAsync.valueOrNull ?? [];
  final maintenanceAlertsCount =
      maintenance.where((m) => m.isOverdue || m.isDueSoon).length;

  return DashboardStats(
    totalKm: totalKm,
    tripsThisMonth: tripsThisMonth,
    kmThisMonth: kmThisMonth,
    drivingHoursThisMonth: drivingHoursThisMonth,
    maintenanceAlertsCount: maintenanceAlertsCount,
  );
});
