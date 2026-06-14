import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehicle/domain/entities/vehicle.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: AppColors.vehicleCardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineLight, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top accent bar ────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // ── Car info row ──────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.primaryLight,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  vehicle.year.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.onSurfaceMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  vehicle.licensePlate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryLight,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(isActive: vehicle.isActive),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(height: 0.8, color: AppColors.outline),
                  const SizedBox(height: 16),

                  // ── Stats row ────────────────────────────
                  Row(
                    children: [
                      _VehicleStat(
                        icon: Icons.speed_rounded,
                        iconColor: AppColors.chartBlue,
                        label: 'Mileage',
                        // mileageDisplay e getter-ul din Vehicle entity
                        value: vehicle.mileageDisplay,
                      ),
                      const _VerticalDivider(),
                      _VehicleStat(
                        icon: Icons.local_gas_station_rounded,
                        iconColor: AppColors.chartTeal,
                        label: 'Fuel',
                        // fuelType.displayName din enum-ul FuelType
                        value: vehicle.fuelType.displayName,
                      ),
                      const _VerticalDivider(),
                      _VehicleStat(
                        icon: Icons.palette_outlined,
                        iconColor: AppColors.chartOrange,
                        label: 'Color',
                        value: vehicle.color ?? '—',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge folosind isActive (bool) ─────────────────
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
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
