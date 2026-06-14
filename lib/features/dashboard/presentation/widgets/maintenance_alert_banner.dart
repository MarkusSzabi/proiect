import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';

class MaintenanceAlertBanner extends StatelessWidget {
  const MaintenanceAlertBanner({super.key, required this.alertsCount});
  final int alertsCount;

  @override
  Widget build(BuildContext context) {
    if (alertsCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.go(RouteNames.maintenance),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$alertsCount maintenance item${alertsCount > 1 ? 's' : ''} need${alertsCount == 1 ? 's' : ''} attention',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warning,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.warning, size: 18),
          ],
        ),
      ),
    );
  }
}
