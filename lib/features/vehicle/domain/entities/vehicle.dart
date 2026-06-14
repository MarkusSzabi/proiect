import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.initialMileageKm,
    required this.currentMileageKm,
    this.fuelType = FuelType.petrol,
    this.color,
    this.vin,
    this.photoUrl,
    this.isActive = false,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final double initialMileageKm;
  final double currentMileageKm;
  final FuelType fuelType;
  final String? color;
  final String? vin;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get displayName => '$year $make $model';
  String get mileageDisplay => '${currentMileageKm.toStringAsFixed(0)} km';

  Vehicle copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    double? initialMileageKm,
    double? currentMileageKm,
    FuelType? fuelType,
    String? color,
    String? vin,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      initialMileageKm: initialMileageKm ?? this.initialMileageKm,
      currentMileageKm: currentMileageKm ?? this.currentMileageKm,
      fuelType: fuelType ?? this.fuelType,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        make,
        model,
        year,
        licensePlate,
        initialMileageKm,
        currentMileageKm,
        fuelType,
        color,
        vin,
        photoUrl,
        isActive,
        createdAt,
      ];
}

enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid,
  lpg;

  String get displayName {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.lpg:
        return 'LPG';
    }
  }
}
