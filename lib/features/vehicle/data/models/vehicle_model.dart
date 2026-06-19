import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.make,
    required super.model,
    required super.year,
    required super.licensePlate,
    required super.initialMileageKm,
    required super.currentMileageKm,
    super.fuelType,
    super.color,
    super.vin,
    super.photoUrl,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory VehicleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return VehicleModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      licensePlate: data['licensePlate'] ?? '',
      initialMileageKm: (data['initialMileageKm'] as num?)?.toDouble() ?? 0,
      currentMileageKm: (data['currentMileageKm'] as num?)?.toDouble() ?? 0,
      fuelType: FuelType.values.firstWhere(
        (e) => e.name == data['fuelType'],
        orElse: () => FuelType.petrol,
      ),
      color: data['color'],
      vin: data['vin'],
      photoUrl: data['photoUrl'],
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory VehicleModel.fromVehicle(Vehicle v) => VehicleModel(
        id: v.id,
        userId: v.userId,
        make: v.make,
        model: v.model,
        year: v.year,
        licensePlate: v.licensePlate,
        initialMileageKm: v.initialMileageKm,
        currentMileageKm: v.currentMileageKm,
        fuelType: v.fuelType,
        color: v.color,
        vin: v.vin,
        photoUrl: v.photoUrl,
        isActive: v.isActive,
        createdAt: v.createdAt,
        updatedAt: v.updatedAt,
      );

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'initialMileageKm': initialMileageKm,
      'currentMileageKm': currentMileageKm,
      'fuelType': fuelType.name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (color != null && color!.trim().isNotEmpty) {
      map['color'] = color!.trim();
    }

    if (vin != null && vin!.trim().isNotEmpty) {
      map['vin'] = vin!.trim();
    }

    return map;
  }
}
