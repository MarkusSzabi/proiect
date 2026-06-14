import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: iconColor.withValues(alpha: 0.25), width: 0.8),
                  ),
                  child: Icon(icon, color: iconColor, size: 15),
                ),
                if (trend != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: trendPositive
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 9,
                            color: trendPositive
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              trend!,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: trendPositive
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
