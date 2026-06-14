import 'package:uuid/uuid.dart';
import '../entities/maintenance_record.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceRecordsUseCase {
  const GetMaintenanceRecordsUseCase(this._repository);
  final MaintenanceRepository _repository;

  Stream<List<MaintenanceRecord>> execute(String vehicleId) =>
      _repository.watchRecords(vehicleId);
}

class SaveMaintenanceRecordUseCase {
  const SaveMaintenanceRecordUseCase(this._repository);
  final MaintenanceRepository _repository;

  Future<MaintenanceRecord> execute({
    required String vehicleId,
    required MaintenanceType type,
    required String title,
    required DateTime date,
    required double mileageAtService,
    double? cost,
    String? notes,
    double? nextServiceMileage,
    DateTime? nextServiceDate,
    String? workshop,
    String? existingId,
  }) async {
    if (title.trim().isEmpty) throw ArgumentError('Title is required');
    if (mileageAtService < 0) throw ArgumentError('Mileage cannot be negative');

    final record = MaintenanceRecord(
      id: existingId ?? const Uuid().v4(),
      vehicleId: vehicleId,
      type: type,
      title: title.trim(),
      date: date,
      mileageAtService: mileageAtService,
      cost: cost,
      notes: notes?.trim(),
      nextServiceMileage: nextServiceMileage,
      nextServiceDate: nextServiceDate,
      workshop: workshop?.trim(),
      createdAt: DateTime.now(),
    );

    return _repository.saveRecord(record);
  }
}

class DeleteMaintenanceRecordUseCase {
  const DeleteMaintenanceRecordUseCase(this._repository);
  final MaintenanceRepository _repository;

  Future<void> execute(String recordId) => _repository.deleteRecord(recordId);
}

class GetUpcomingServicesUseCase {
  const GetUpcomingServicesUseCase(this._repository);
  final MaintenanceRepository _repository;

  Future<List<MaintenanceRecord>> execute(String vehicleId) =>
      _repository.getUpcomingServices(vehicleId);
}
