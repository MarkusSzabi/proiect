import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../maintenance/domain/entities/maintenance_record.dart';
import '../../../maintenance/presentation/providers/maintenance_provider.dart';

class MaintenanceTimelineWidget extends ConsumerWidget {
  const MaintenanceTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(maintenanceRecordsProvider);

    return recordsAsync.when(
      loading: () => _buildSkeleton(),
      error: (e, _) => _buildError(),
      data: (records) {
        if (records.isEmpty) return _buildEmpty(context);

        // Prioritizam: overdue > due soon > cele cu next service date
        final relevant = records
            .where(
                (r) => r.isOverdue || r.isDueSoon || r.nextServiceDate != null)
            .toList()
          ..sort((a, b) {
            if (a.isOverdue && !b.isOverdue) return -1;
            if (!a.isOverdue && b.isOverdue) return 1;
            if (a.isDueSoon && !b.isDueSoon) return -1;
            if (!a.isDueSoon && b.isDueSoon) return 1;
            final aNext = a.nextServiceDate;
            final bNext = b.nextServiceDate;
            if (aNext != null && bNext != null) return aNext.compareTo(bNext);
            if (aNext != null) return -1;
            if (bNext != null) return 1;
            return 0;
          });

        if (relevant.isEmpty) return _buildAllClear();

        final displayed = relevant.take(3).toList();

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline, width: 0.8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < displayed.length; i++) ...[
                _MaintenanceTile(
                  record: displayed[i],
                  isLast: i == displayed.length - 1,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 0.8),
      ),
      child: Column(
        children: List.generate(
            3,
            (i) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 12,
                                width: 120,
                                color: AppColors.surfaceVariant),
                            const SizedBox(height: 6),
                            Container(
                                height: 10,
                                width: 80,
                                color: AppColors.surfaceVariant),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No maintenance records yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add your first service record to track maintenance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllClear() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: AppColors.success,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'All clear!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No upcoming or overdue maintenance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
          SizedBox(width: 10),
          Text(
            'Failed to load maintenance data',
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

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({required this.record, this.isLast = false});

  final MaintenanceRecord record;
  final bool isLast;

  Color get _urgencyColor {
    if (record.isOverdue) return AppColors.danger;
    if (record.isDueSoon) return AppColors.warning;
    return AppColors.success;
  }

  String get _urgencyLabel {
    if (record.isOverdue) return 'Overdue';
    if (record.isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  IconData get _typeIcon {
    switch (record.type) {
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
    final nextDate = record.nextServiceDate;
    final displayDate = nextDate ?? record.date;
    final dateStr = DateFormat('dd MMM yyyy').format(displayDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _urgencyColor.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: Icon(_typeIcon, color: _urgencyColor, size: 18),
              ),
              const SizedBox(width: 14),
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _urgencyColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _urgencyLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _urgencyColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
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
                            Icon(Icons.calendar_today_outlined,
                                size: 10, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              nextDate != null ? 'Next: $dateStr' : dateStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        if (record.nextServiceMileage != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.speed_outlined,
                                  size: 10, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${record.nextServiceMileage!.toStringAsFixed(0)} km',
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
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 0.8,
            color: AppColors.outline,
          ),
      ],
    );
  }
}
