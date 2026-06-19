import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_driver_assistant/core/constants/route_names.dart';
import 'package:smart_driver_assistant/core/theme/app_colors.dart';
import 'package:smart_driver_assistant/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_driver_assistant/features/maintenance/presentation/providers/maintenance_provider.dart';
import 'package:smart_driver_assistant/features/trip/presentation/providers/trip_provider.dart';
import 'package:smart_driver_assistant/features/vehicle/domain/entities/vehicle.dart';
import 'package:smart_driver_assistant/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:smart_driver_assistant/features/dashboard/presentation/widgets/vehicle_card.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesStreamProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onSurface,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: AppColors.outline),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addVehicle),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Vehicle',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ListErrorState(
          title: 'Could not load vehicles',
          message: 'Please try again. Error: $e',
        ),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(
              onAdd: () => context.push(RouteNames.addVehicle),
            );
          }

          final sorted = [...list]..sort((a, b) {
              if (a.isActive == b.isActive) {
                return a.displayName.toLowerCase().compareTo(
                      b.displayName.toLowerCase(),
                    );
              }
              return a.isActive ? -1 : 1;
            });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _VehicleSummaryRow(
                total: sorted.length,
                active: sorted.where((v) => v.isActive).length,
              ),
              const SizedBox(height: 18),
              ...sorted.map(
                (vehicle) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: VehicleCard(
                    vehicle: vehicle,
                    onTap: () => _showVehicleDetails(context, ref, vehicle),
                    trailing: _VehicleCardActions(
                      vehicle: vehicle,
                      onSetActive: () {
                        if (user != null) {
                          ref
                              .read(vehicleNotifierProvider.notifier)
                              .setActive(user.uid, vehicle.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${vehicle.displayName} set as active.'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      onEdit: () =>
                          context.push(RouteNames.addVehicle, extra: vehicle),
                      onDelete: () async {
                        final confirmed =
                            await _confirmDelete(context, vehicle.displayName);

                        if (confirmed) {
                          await ref
                              .read(vehicleNotifierProvider.notifier)
                              .deleteVehicle(vehicle.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${vehicle.displayName} deleted.'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVehicleDetails(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleDetailSheet(vehicle: vehicle),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String vehicleName) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Delete Vehicle',
              style: TextStyle(
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Delete "$vehicleName"? All related trips and maintenance records may be lost.',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _VehicleCardActions extends StatelessWidget {
  const _VehicleCardActions({
    required this.vehicle,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.onSurfaceVariant,
      ),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        switch (value) {
          case 'active':
            onSetActive();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        if (!vehicle.isActive)
          const PopupMenuItem<String>(
            value: 'active',
            child: Text('Set as active'),
          ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
  }
}

class _VehicleSummaryRow extends StatelessWidget {
  const _VehicleSummaryRow({
    required this.total,
    required this.active,
  });

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryCard(
          label: 'Vehicles',
          value: total.toString(),
          color: AppColors.primary,
          icon: Icons.directions_car_outlined,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Active',
          value: active.toString(),
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDetailSheet extends ConsumerWidget {
  const _VehicleDetailSheet({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTrips = ref.watch(tripsStreamProvider).valueOrNull ?? [];
    final vehicleTrips = allTrips
        .where((t) => t.vehicleId == vehicle.id && !t.isActive)
        .toList();
    final totalTripKm = vehicleTrips.fold(0.0, (sum, t) => sum + t.distanceKm);

    final allMaintenance = ref
            .watch(maintenanceRecordsByVehicleProvider(vehicle.id))
            .valueOrNull ??
        [];
    final pendingMaintenance =
        allMaintenance.where((m) => m.isOverdue || m.isDueSoon).length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: vehicle.isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: vehicle.isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          vehicle.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (vehicle.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${vehicle.licensePlate} · ${vehicle.fuelType.displayName}${vehicle.color != null && vehicle.color!.isNotEmpty ? ' · ${vehicle.color}' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 0.5, color: AppColors.outline),
          const SizedBox(height: 16),
          Row(
            children: [
              _DetailStat(
                icon: Icons.speed_outlined,
                color: AppColors.primary,
                label: 'Current km',
                value: '${vehicle.currentMileageKm.toStringAsFixed(0)} km',
              ),
              _DetailStat(
                icon: Icons.route_outlined,
                color: AppColors.success,
                label: 'Trip km',
                value: '${totalTripKm.toStringAsFixed(0)} km',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DetailStat(
                icon: Icons.build_circle_outlined,
                color: AppColors.warning,
                label: 'Service alerts',
                value: '$pendingMaintenance',
              ),
              _DetailStat(
                icon: Icons.calendar_today_outlined,
                color: AppColors.primaryLight,
                label: 'Year',
                value: vehicle.year.toString(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (vehicle.vin != null && vehicle.vin!.isNotEmpty)
            _InfoRow(label: 'VIN', value: vehicle.vin!),
          if (vehicle.vin != null && vehicle.vin!.isNotEmpty)
            const SizedBox(height: 10),
          _InfoRow(
            label: 'Initial mileage',
            value: '${vehicle.initialMileageKm.toStringAsFixed(0)} km',
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No vehicles added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first vehicle to start tracking trips, documents, and maintenance records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add First Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListErrorState extends StatelessWidget {
  const _ListErrorState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
