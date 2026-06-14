import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/insight_data.dart';
import '../providers/insights_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(statisticsProvider),
          ),
        ],
      ),
      body: activeVehicle == null
          ? _NoVehiclePrompt()
          : stats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) => _StatisticsContent(
                summary: data,
                vehicleName: activeVehicle.displayName,
              ),
            ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.summary,
    required this.vehicleName,
  });

  final StatsSummary summary;
  final String vehicleName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle name
        Text(
          vehicleName,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Last 3 months',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.route_outlined,
                label: 'Total km',
                value: summary.totalKm.toStringAsFixed(1),
                unit: 'km',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.directions_car_outlined,
                label: 'Total trips',
                value: summary.totalTrips.toString(),
                unit: 'trips',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.speed_outlined,
                label: 'Avg/trip',
                value: summary.avgKmPerTrip.toStringAsFixed(1),
                unit: 'km',
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bar chart
        if (summary.monthlyStats.isNotEmpty) ...[
          const Text(
            'KM PER MONTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _KmBarChart(monthlyStats: summary.monthlyStats),
          const SizedBox(height: 24),

          // Monthly breakdown list
          const Text(
            'MONTHLY BREAKDOWN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...summary.monthlyStats.reversed.map(
            (m) => _MonthTile(stats: m),
          ),
        ] else
          _EmptyTripsState(),
      ],
    );
  }
}

class _KmBarChart extends StatelessWidget {
  const _KmBarChart({required this.monthlyStats});
  final List<MonthlyStats> monthlyStats;

  @override
  Widget build(BuildContext context) {
    final maxKm =
        monthlyStats.map((m) => m.totalKm).fold(0.0, (a, b) => a > b ? a : b);

    final maxY = maxKm > 0 ? (maxKm * 1.3).ceilToDouble() : 100.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final m = monthlyStats[groupIndex];
                return BarTooltipItem(
                  '${m.monthLabel}\n${m.totalKm.toStringAsFixed(1)} km',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthlyStats.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      monthlyStats[idx].monthLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxY) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyStats.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            final isLatest = idx == monthlyStats.length - 1;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: m.totalKm,
                  color: isLatest
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4),
                  width: 32,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MonthTile extends StatelessWidget {
  const _MonthTile({required this.stats});
  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
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
            child: Center(
              child: Text(
                stats.monthLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.monthYearLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stats.tripCount} trip${stats.tripCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stats.totalKm.toStringAsFixed(1)} km',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: stats.totalKm > 0
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTripsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No trips yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some trips to see your statistics',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoVehiclePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No vehicle selected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add a vehicle first to see statistics',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
