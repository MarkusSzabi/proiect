import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../maintenance/presentation/providers/maintenance_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../domain/entities/vehicle.dart';
import '../providers/vehicle_provider.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesStreamProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addVehicle),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(
              onAdd: () => context.push(RouteNames.addVehicle),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final vehicle = list[index];
              return _VehicleTile(
                vehicle: vehicle,
                onTap: () {
                  // Click pe vehicul il seteaza activ si arata detalii
                  if (!vehicle.isActive && user != null) {
                    ref
                        .read(vehicleNotifierProvider.notifier)
                        .setActive(user.uid, vehicle.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${vehicle.displayName} set as active'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  // Arata detaliile vehiculului
                  _showVehicleDetails(context, ref, vehicle, user?.uid ?? '');
                },
                onSetActive: () {
                  if (user != null) {
                    ref
                        .read(vehicleNotifierProvider.notifier)
                        .setActive(user.uid, vehicle.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${vehicle.displayName} set as active'),
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
                  final confirmed = await _confirmDelete(context, vehicle.displayName);
                  if (confirmed) {
                    await ref
                        .read(vehicleNotifierProvider.notifier)
                        .deleteVehicle(vehicle.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showVehicleDetails(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleDetailSheet(vehicle: vehicle, ref: ref),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String vehicleName) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Vehicle'),
            content: Text(
                'Delete "$vehicleName"? All trips and maintenance records will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ── Vehicle Detail Bottom Sheet ───────────────────────────

class _VehicleDetailSheet extends ConsumerWidget {
  const _VehicleDetailSheet({required this.vehicle, required this.ref});
  final Vehicle vehicle;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trips pentru acest vehicul specific
    final allTrips = ref.watch(tripsStreamProvider).valueOrNull ?? [];
    final vehicleTrips =
        allTrips.where((t) => t.vehicleId == vehicle.id && !t.isActive).toList();
    final totalTripKm =
        vehicleTrips.fold(0.0, (sum, t) => sum + t.distanceKm);

    // Maintenance pentru acest vehicul
    final allMaintenance =
        ref.watch(maintenanceRecordsByVehicleProvider(vehicle.id)).valueOrNull ?? [];
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
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
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
                    Row(
                      children: [
                        Text(
                          vehicle.displayName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        if (vehicle.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Active',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${vehicle.licensePlate} · ${vehicle.fuelType.displayName}${vehicle.color != null ? ' · ${vehicle.color}' : ''}',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(height: 0.5, color: AppColors.outline),
          const SizedBox(height: 16),

          // Stats grid
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
              _DetailStat(
                icon: Icons.directions_car_outlined,
                color: AppColors.accent,
                label: 'Trips',
                value: vehicleTrips.length.toString(),
              ),
              _DetailStat(
                icon: Icons.build_outlined,
                color: pendingMaintenance > 0
                    ? AppColors.warning
                    : AppColors.onSurfaceVariant,
                label: 'Alerts',
                value: pendingMaintenance.toString(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              if (!vehicle.isActive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final user = ref.read(authStateProvider).valueOrNull;
                      if (user != null) {
                        ref
                            .read(vehicleNotifierProvider.notifier)
                            .setActive(user.uid, vehicle.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${vehicle.displayName} is now active'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Set Active'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              if (!vehicle.isActive) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to edit
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.outline),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Vehicle Tile ──────────────────────────────────────────

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.onTap,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: vehicle.isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.outline,
            width: vehicle.isActive ? 1.5 : 0.5,
          ),
          boxShadow: vehicle.isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: vehicle.isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: vehicle.isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.displayName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vehicle.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${vehicle.licensePlate} · ${vehicle.mileageDisplay}',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.onSurfaceMuted, size: 20),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: AppColors.onSurfaceVariant, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'activate':
                    onSetActive();
                  case 'edit':
                    onEdit();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (_) => [
                if (!vehicle.isActive)
                  const PopupMenuItem(
                      value: 'activate', child: Text('Set as Active')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: AppColors.onSurfaceMuted),
          const SizedBox(height: 16),
          const Text('No vehicles yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add your first vehicle to get started',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
          ),
        ],
      ),
    );
  }
}