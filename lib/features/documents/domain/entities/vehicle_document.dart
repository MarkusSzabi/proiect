enum DocumentType {
  insurance,
  itp,
  rovinieta,
  rcaCard,
  registrationCertificate,
  drivingLicense,
  other;

  String get displayName {
    switch (this) { 
      case DocumentType.insurance:
        return 'Insurance (CASCO)';
      case DocumentType.itp:
        return 'ITP';
      case DocumentType.rovinieta:
        return 'Rovinieta';
      case DocumentType.rcaCard:
        return 'RCA';
      case DocumentType.registrationCertificate:
        return 'Registration Certificate';
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.insurance:
        return '🛡️';
      case DocumentType.itp:
        return '🔧';
      case DocumentType.rovinieta:
        return '🛣️';
      case DocumentType.rcaCard:
        return '📋';
      case DocumentType.registrationCertificate:
        return '📄';
      case DocumentType.drivingLicense:
        return '🪪';
      case DocumentType.other:
        return '📁';
    }
  }
}

class VehicleDocument {
  const VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.expiryDate,
    this.reminderDaysBefore = 30,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final DocumentType type;
  final DateTime expiryDate;
  final int reminderDaysBefore;
  final String? notes;
  final DateTime createdAt;

  int get daysUntilExpiry =>
      expiryDate.difference(DateTime.now()).inDays;

  bool get isExpired => daysUntilExpiry < 0;

  bool get isExpiringSoon =>
      daysUntilExpiry >= 0 && daysUntilExpiry <= reminderDaysBefore;

  String get statusDisplay {
    if (isExpired) return 'Expired';
    if (isExpiringSoon) return 'Expires in $daysUntilExpiry days';
    return 'Valid';
  }

  VehicleDocument copyWith({
    String? id,
    String? vehicleId,
    DocumentType? type,
    DateTime? expiryDate,
    int? reminderDaysBefore,
    String? notes,
    DateTime? createdAt,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}