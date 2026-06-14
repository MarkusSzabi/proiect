enum MaintenanceType {
  oilChange,
  tireRotation,
  brakeService,
  airFilter,
  sparkPlugs,
  transmission,
  coolant,
  battery,
  timing,
  inspection,
  other;

  String get displayName {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.tireRotation:
        return 'Tire Rotation';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.airFilter:
        return 'Air Filter';
      case MaintenanceType.sparkPlugs:
        return 'Spark Plugs';
      case MaintenanceType.transmission:
        return 'Transmission';
      case MaintenanceType.coolant:
        return 'Coolant';
      case MaintenanceType.battery:
        return 'Battery';
      case MaintenanceType.timing:
        return 'Timing Belt/Chain';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case MaintenanceType.oilChange:
        return '🛢️';
      case MaintenanceType.tireRotation:
        return '🔄';
      case MaintenanceType.brakeService:
        return '🛑';
      case MaintenanceType.airFilter:
        return '💨';
      case MaintenanceType.sparkPlugs:
        return '⚡';
      case MaintenanceType.transmission:
        return '⚙️';
      case MaintenanceType.coolant:
        return '🌡️';
      case MaintenanceType.battery:
        return '🔋';
      case MaintenanceType.timing:
        return '⏱️';
      case MaintenanceType.inspection:
        return '🔍';
      case MaintenanceType.other:
        return '🔧';
    }
  }
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.title,
    required this.date,
    required this.mileageAtService,
    this.cost,
    this.notes,
    this.nextServiceMileage,
    this.nextServiceDate,
    this.workshop,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final MaintenanceType type;
  final String title;
  final DateTime date;
  final double mileageAtService;
  final double? cost;
  final String? notes;
  final double? nextServiceMileage;
  final DateTime? nextServiceDate;
  final String? workshop;
  final DateTime createdAt;

  bool get isDueSoon {
    if (nextServiceDate != null) {
      final daysLeft = nextServiceDate!.difference(DateTime.now()).inDays;
      return daysLeft <= 30 && daysLeft >= 0;
    }
    return false;
  }

  bool get isOverdue {
    if (nextServiceDate != null) {
      return nextServiceDate!.isBefore(DateTime.now());
    }
    return false;
  }

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    MaintenanceType? type,
    String? title,
    DateTime? date,
    double? mileageAtService,
    double? cost,
    String? notes,
    double? nextServiceMileage,
    DateTime? nextServiceDate,
    String? workshop,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      workshop: workshop ?? this.workshop,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
