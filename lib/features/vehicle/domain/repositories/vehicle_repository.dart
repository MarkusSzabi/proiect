import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Stream<List<Vehicle>> watchVehicles(String userId);
  Future<Vehicle?> getActiveVehicle(String userId);
  Future<Vehicle> saveVehicle(Vehicle vehicle);
  Future<void> updateMileage(String vehicleId, double additionalKm);
  Future<void> setActiveVehicle(String userId, String vehicleId);
  Future<void> deleteVehicle(String vehicleId);
}
