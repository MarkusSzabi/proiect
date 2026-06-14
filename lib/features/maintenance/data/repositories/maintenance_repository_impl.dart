import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_datasource.dart';
import '../models/maintenance_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  const MaintenanceRepositoryImpl(this._dataSource);
  final MaintenanceRemoteDataSource _dataSource;

  @override
  Stream<List<MaintenanceRecord>> watchRecords(String vehicleId) =>
      _dataSource.watchRecords(vehicleId);

  @override
  Future<MaintenanceRecord> saveRecord(MaintenanceRecord record) =>
      _dataSource.saveRecord(MaintenanceModel.fromRecord(record));

  @override
  Future<void> deleteRecord(String recordId) =>
      _dataSource.deleteRecord(recordId);

  @override
  Future<List<MaintenanceRecord>> getUpcomingServices(String vehicleId) =>
      _dataSource.getUpcomingServices(vehicleId);
}
