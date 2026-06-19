import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/maintenance_record.dart';
import '../providers/maintenance_provider.dart';
import 'add_maintenance_screen.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final allMaintenance = ref.watch(maintenanceRecordsByVehicleProvider(
      activeVehicle?.id ?? '',
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      floatingActionButton: activeVehicle == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMaintenanceScreen(
                      vehicleId: activeVehicle.id,
                    ),
                  ),
                );
                ref.invalidate(
                    maintenanceRecordsByVehicleProvider(activeVehicle.id));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Record'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      body: activeVehicle == null
          ? const _NoVehiclePrompt()
          : allMaintenance.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ListErrorState(message: 'Error: $e'),
              data: (list) {
                final sorted = [...list]
                  ..sort((a, b) => b.date.compareTo(a.date));

                if (sorted.isEmpty) return const _EmptyState();

                return _MaintenanceList(
                  records: sorted,
                  onDeleted: () => ref.invalidate(
                      maintenanceRecordsByVehicleProvider(activeVehicle.id)),
                  onEdited: () => ref.invalidate(
                      maintenanceRecordsByVehicleProvider(activeVehicle.id)),
                  vehicleId: activeVehicle.id,
                );
              },
            ),
    );
  }
}

class _MaintenanceList extends ConsumerWidget {
  const _MaintenanceList({
    required this.records,
    required this.onDeleted,
    required this.onEdited,
    required this.vehicleId,
  });

  final List<MaintenanceRecord> records;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = records.where((r) => r.isOverdue).toList();
    final dueSoon = records.where((r) => r.isDueSoon && !r.isOverdue).toList();
    final completed =
        records.where((r) => !r.isOverdue && !r.isDueSoon).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _SummaryRow(
          total: records.length,
          overdue: overdue.length,
          dueSoon: dueSoon.length,
        ),
        const SizedBox(height: 18),
        if (overdue.isNotEmpty) ...[
          const _GroupHeader(label: 'Overdue', color: AppColors.danger),
          const SizedBox(height: 8),
          ...overdue.map(
            (r) => _MaintenanceTile(
              record: r,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMaintenanceScreen(
                      vehicleId: vehicleId,
                      existingRecord: r,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed = await _confirmDelete(context, r.title);
                if (confirmed) {
                  await ref
                      .read(maintenanceNotifierProvider.notifier)
                      .deleteRecord(r.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${r.title} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (dueSoon.isNotEmpty) ...[
          const _GroupHeader(label: 'Due Soon', color: AppColors.warning),
          const SizedBox(height: 8),
          ...dueSoon.map(
            (r) => _MaintenanceTile(
              record: r,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMaintenanceScreen(
                      vehicleId: vehicleId,
                      existingRecord: r,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed = await _confirmDelete(context, r.title);
                if (confirmed) {
                  await ref
                      .read(maintenanceNotifierProvider.notifier)
                      .deleteRecord(r.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${r.title} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          const _GroupHeader(label: 'Completed', color: AppColors.success),
          const SizedBox(height: 8),
          ...completed.map(
            (r) => _MaintenanceTile(
              record: r,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMaintenanceScreen(
                      vehicleId: vehicleId,
                      existingRecord: r,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed = await _confirmDelete(context, r.title);
                if (confirmed) {
                  await ref
                      .read(maintenanceNotifierProvider.notifier)
                      .deleteRecord(r.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${r.title} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String recordName) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Record'),
            content: Text(
              'Are you sure you want to delete "$recordName"?',
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.overdue,
    required this.dueSoon,
  });

  final int total;
  final int overdue;
  final int dueSoon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryCard(
          label: 'Total',
          value: total.toString(),
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Overdue',
          value: overdue.toString(),
          color: AppColors.danger,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Soon',
          value: dueSoon.toString(),
          color: AppColors.warning,
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
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final MaintenanceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _iconFor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return Icons.oil_barrel_rounded;
      case MaintenanceType.tireRotation:
        return Icons.tire_repair_rounded;
      case MaintenanceType.brakeService:
        return Icons.emergency_rounded;
      case MaintenanceType.battery:
        return Icons.battery_charging_full_rounded;
      case MaintenanceType.airFilter:
        return Icons.air_rounded;
      case MaintenanceType.inspection:
        return Icons.fact_check_rounded;
      case MaintenanceType.sparkPlugs:
        return Icons.bolt_rounded;
      case MaintenanceType.transmission:
        return Icons.settings_rounded;
      case MaintenanceType.coolant:
        return Icons.thermostat_rounded;
      case MaintenanceType.timing:
        return Icons.timer_rounded;
      case MaintenanceType.other:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = record.isOverdue
        ? AppColors.danger
        : record.isDueSoon
            ? AppColors.warning
            : AppColors.success;

    final dateStr = DateFormat('dd MMM yyyy').format(record.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: record.isOverdue
              ? AppColors.danger.withValues(alpha: 0.4)
              : record.isDueSoon
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : AppColors.outline.withValues(alpha: 0.3),
          width: (record.isOverdue || record.isDueSoon) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(record.type),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: Icons.speed_outlined,
                label: '${record.mileageAtService.toStringAsFixed(0)} km',
              ),
              const SizedBox(width: 8),
              if (record.cost != null)
                _InfoChip(
                  icon: Icons.attach_money,
                  label: '${record.cost!.toStringAsFixed(0)} RON',
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.isOverdue
                      ? 'Overdue'
                      : record.isDueSoon
                          ? 'Due Soon'
                          : 'Completed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (record.workshop != null && record.workshop!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  record.workshop!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.build_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No maintenance records yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the add button to save your first service record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoVehiclePrompt extends StatelessWidget {
  const _NoVehiclePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No vehicle selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add or select a vehicle first to manage maintenance records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListErrorState extends StatelessWidget {
  const _ListErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 14),
            const Text(
              'Could not load maintenance records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
