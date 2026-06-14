import '../entities/maintenance_record.dart';

abstract class MaintenanceRepository {
  Stream<List<MaintenanceRecord>> watchRecords(String vehicleId);
  Future<MaintenanceRecord> saveRecord(MaintenanceRecord record);
  Future<void> deleteRecord(String recordId);
  Future<List<MaintenanceRecord>> getUpcomingServices(String vehicleId);
}