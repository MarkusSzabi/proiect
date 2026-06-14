import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl(this._dataSource);
  final VehicleRemoteDataSource _dataSource;

  @override
  Stream<List<Vehicle>> watchVehicles(String userId) =>
      _dataSource.watchVehicles(userId);

  @override
  Future<Vehicle?> getActiveVehicle(String userId) async {
    final vehicles = await _dataSource.watchVehicles(userId).first;
    try {
      return vehicles.firstWhere((v) => v.isActive);
    } catch (_) {
      return vehicles.isNotEmpty ? vehicles.first : null;
    }
  }

  @override
  Future<Vehicle> saveVehicle(Vehicle vehicle) =>
      _dataSource.saveVehicle(VehicleModel.fromVehicle(vehicle));

  @override
  Future<void> updateMileage(String vehicleId, double additionalKm) =>
      _dataSource.updateMileage(vehicleId, additionalKm);

  @override
  Future<void> setActiveVehicle(String userId, String vehicleId) =>
      _dataSource.setActiveVehicle(userId, vehicleId);

  @override
  Future<void> deleteVehicle(String vehicleId) =>
      _dataSource.deleteVehicle(vehicleId);
}
