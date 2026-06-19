import 'package:flutter/material.dart';
import 'package:smart_driver_assistant/core/theme/app_colors.dart';
import 'package:smart_driver_assistant/features/vehicle/domain/entities/vehicle.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.compact = false,
  });

  final Vehicle vehicle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.vehicleCardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: vehicle.isActive
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : AppColors.outlineLight,
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: vehicle.isActive
                      ? AppColors.accentGradient
                      : LinearGradient(
                          colors: [
                            AppColors.outline.withValues(alpha: 0.35),
                            AppColors.outline.withValues(alpha: 0.12),
                          ],
                        ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 16 : 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: vehicle.isActive
                                ? AppColors.primaryGradient
                                : null,
                            color: vehicle.isActive
                                ? null
                                : AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: vehicle.isActive
                                  ? AppColors.primary.withValues(alpha: 0.35)
                                  : AppColors.primary.withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: vehicle.isActive
                                ? Colors.white
                                : AppColors.primaryLight,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.make} ${vehicle.model}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    vehicle.year.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: AppColors.onSurfaceMuted,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      vehicle.licensePlate,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primaryLight,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (trailing != null) trailing!,
                        if (trailing == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatusBadge(isActive: vehicle.isActive),
                              if (showChevron) ...[
                                const SizedBox(height: 10),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.75),
                                  size: 22,
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 0.8, color: AppColors.outline),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _VehicleStat(
                          icon: Icons.speed_rounded,
                          iconColor: AppColors.chartBlue,
                          label: 'Mileage',
                          value: vehicle.mileageDisplay,
                        ),
                        const _VerticalDivider(),
                        _VehicleStat(
                          icon: Icons.local_gas_station_rounded,
                          iconColor: AppColors.chartTeal,
                          label: 'Fuel',
                          value: vehicle.fuelType.displayName,
                        ),
                        const _VerticalDivider(),
                        _VehicleStat(
                          icon: Icons.palette_outlined,
                          iconColor: AppColors.chartOrange,
                          label: 'Color',
                          value: (vehicle.color != null &&
                                  vehicle.color!.trim().isNotEmpty)
                              ? vehicle.color!
                              : '—',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.onSurfaceMuted;
    final label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStat extends StatelessWidget {
  const _VehicleStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8,
      height: 40,
      color: AppColors.outline,
    );
  }
}
