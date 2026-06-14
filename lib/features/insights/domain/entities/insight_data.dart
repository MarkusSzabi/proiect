class MonthlyStats {
  const MonthlyStats({
    required this.month,
    required this.year,
    required this.totalKm,
    required this.tripCount,
  });

  final int month;
  final int year;
  final double totalKm;
  final int tripCount;

  String get monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String get monthYearLabel => '$monthLabel $year';
}

class StatsSummary {
  const StatsSummary({
    required this.totalKm,
    required this.totalTrips,
    required this.avgKmPerTrip,
    required this.monthlyStats,
  });

  final double totalKm;
  final int totalTrips;
  final double avgKmPerTrip;
  final List<MonthlyStats> monthlyStats;
}