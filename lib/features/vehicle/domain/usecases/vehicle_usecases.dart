import 'package:uuid/uuid.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class SaveVehicleUseCase {
  const SaveVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Vehicle> execute({
    required String userId,
    required String make,
    required String model,
    required int year,
    required String licensePlate,
    required double initialMileageKm,
    FuelType fuelType = FuelType.petrol,
    String? color,
    String? vin,
    String? existingId,
  }) async {
    if (make.trim().isEmpty) throw ArgumentError('Make is required');
    if (model.trim().isEmpty) throw ArgumentError('Model is required');
    if (year < 1900 || year > DateTime.now().year + 1) {
      throw ArgumentError('Invalid year');
    }
    if (initialMileageKm < 0) throw ArgumentError('Mileage cannot be negative');

    final vehicle = Vehicle(
      id: existingId ?? const Uuid().v4(),
      userId: userId,
      make: make.trim(),
      model: model.trim(),
      year: year,
      licensePlate: licensePlate.trim().toUpperCase(),
      initialMileageKm: initialMileageKm,
      currentMileageKm: initialMileageKm,
      fuelType: fuelType,
      color: color?.trim(),
      vin: vin?.trim().toUpperCase(),
      isActive: false,
      createdAt: DateTime.now(),
    );

    return _repository.saveVehicle(vehicle);
  }
}

class GetVehiclesUseCase {
  const GetVehiclesUseCase(this._repository);
  final VehicleRepository _repository;

  Stream<List<Vehicle>> execute(String userId) =>
      _repository.watchVehicles(userId);
}

class SetActiveVehicleUseCase {
  const SetActiveVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<void> execute(String userId, String vehicleId) =>
      _repository.setActiveVehicle(userId, vehicleId);
}

class DeleteVehicleUseCase {
  const DeleteVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<void> execute(String vehicleId) =>
      _repository.deleteVehicle(vehicleId);
}
