enum TripCategory { personal, business }

class Trip {
  const Trip({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.startLocationName,
    this.endLocationName,
    this.distanceKm = 0,
    this.isActive = false,
    this.category = TripCategory.personal,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? startLocationName;
  final String? endLocationName;
  final double distanceKm;
  final bool isActive;
  final TripCategory category;
  final DateTime createdAt;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get durationDisplay {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get distanceDisplay => '${distanceKm.toStringAsFixed(1)} km';

  Trip copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? startLocationName,
    String? endLocationName,
    double? distanceKm,
    bool? isActive,
    TripCategory? category,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startLocationName: startLocationName ?? this.startLocationName,
      endLocationName: endLocationName ?? this.endLocationName,
      distanceKm: distanceKm ?? this.distanceKm,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}