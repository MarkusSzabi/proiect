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
    final records = ref.watch(maintenanceRecordsProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        actions: [
          if (activeVehicle != null)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(context),
            ),
        ],
      ),
      floatingActionButton: activeVehicle == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddMaintenanceScreen(vehicleId: activeVehicle.id),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      body: activeVehicle == null
          ? const _NoVehiclePrompt()
          : records.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyState(vehicleId: activeVehicle.id);
                }
                return _RecordsList(records: list, vehicleId: activeVehicle.id);
              },
            ),
    );
  }

  void _showFilterSheet(BuildContext context) {}
}

class _RecordsList extends ConsumerWidget {
  const _RecordsList({required this.records, required this.vehicleId});
  final List<MaintenanceRecord> records;
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = <int, List<MaintenanceRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.date.year, () => []).add(r);
    }
    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: years.length,
      itemBuilder: (_, i) {
        final year = years[i];
        final yearRecords = grouped[year]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                year.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
            ...yearRecords.map((r) => _RecordTile(
                  record: r,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMaintenanceScreen(
                        vehicleId: vehicleId,
                        existingRecord: r,
                      ),
                    ),
                  ),
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed) {
                      await ref
                          .read(maintenanceNotifierProvider.notifier)
                          .deleteRecord(r.id);
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
            title: const Text('Delete Record'),
            content: const Text('Are you sure you want to delete this record?'),
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

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });
  final MaintenanceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(record.date);
    final isAlert = record.isOverdue || record.isDueSoon;

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
          width: isAlert ? 1.5 : 1,
        ),
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
            child: Icon(
              _typeIcon(record.type),
              color: AppColors.primary,
              size: 20,
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
                        record.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (record.isOverdue)
                      _Badge(label: 'Overdue', color: AppColors.danger)
                    else if (record.isDueSoon)
                      _Badge(label: 'Due Soon', color: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(dateStr,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed_outlined,
                            size: 11, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${record.mileageAtService.toStringAsFixed(0)} km',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    if (record.cost != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments_outlined,
                              size: 11, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${record.cost!.toStringAsFixed(0)} RON',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                  ],
                ),
                if (record.nextServiceDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Next: ${DateFormat('dd MMM yyyy').format(record.nextServiceDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: record.isOverdue
                          ? AppColors.danger
                          : record.isDueSoon
                              ? AppColors.warning
                              : AppColors.onSurfaceVariant,
                      fontWeight: isAlert ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.onSurfaceVariant, size: 20),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child:
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(MaintenanceType type) {
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
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.build_outlined, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          const Text('No maintenance records yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + to add your first service record',
              style: TextStyle(color: Colors.grey.shade500)),
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
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          const Text('No vehicle selected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add a vehicle first to track maintenance',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
