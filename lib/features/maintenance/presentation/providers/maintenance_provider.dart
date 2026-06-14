import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/maintenance_remote_datasource.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/usecases/maintenance_usecases.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';

// ── Infrastructure ────────────────────────────────────────

final maintenanceDataSourceProvider =
    Provider<MaintenanceRemoteDataSource>((ref) {
  return MaintenanceRemoteDataSourceImpl(ref.read(firestoreProvider));
});

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepositoryImpl(ref.read(maintenanceDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────

final getMaintenanceRecordsUseCaseProvider =
    Provider<GetMaintenanceRecordsUseCase>((ref) {
  return GetMaintenanceRecordsUseCase(ref.read(maintenanceRepositoryProvider));
});

final saveMaintenanceRecordUseCaseProvider =
    Provider<SaveMaintenanceRecordUseCase>((ref) {
  return SaveMaintenanceRecordUseCase(ref.read(maintenanceRepositoryProvider));
});

final deleteMaintenanceRecordUseCaseProvider =
    Provider<DeleteMaintenanceRecordUseCase>((ref) {
  return DeleteMaintenanceRecordUseCase(
      ref.read(maintenanceRepositoryProvider));
});

// ── Stream pentru recordurile vehiculului activ ───────────

final maintenanceRecordsProvider =
    StreamProvider<List<MaintenanceRecord>>((ref) {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return Stream.value([]);
  return ref
      .read(getMaintenanceRecordsUseCaseProvider)
      .execute(activeVehicle.id);
});

// ── Stream pentru un vehicul specific ─────────────────────

final maintenanceRecordsByVehicleProvider =
    StreamProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) {
  return ref.read(getMaintenanceRecordsUseCaseProvider).execute(vehicleId);
});

// ── Save state ────────────────────────────────────────────

enum MaintenanceSaveStatus { initial, loading, success, error }

class MaintenanceSaveState {
  const MaintenanceSaveState({
    this.status = MaintenanceSaveStatus.initial,
    this.errorMessage,
  });
  final MaintenanceSaveStatus status;
  final String? errorMessage;

  bool get isLoading => status == MaintenanceSaveStatus.loading;
}

class MaintenanceNotifier extends StateNotifier<MaintenanceSaveState> {
  MaintenanceNotifier(this._saveUseCase, this._deleteUseCase)
      : super(const MaintenanceSaveState());

  final SaveMaintenanceRecordUseCase _saveUseCase;
  final DeleteMaintenanceRecordUseCase _deleteUseCase;

  Future<bool> saveRecord({
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
    state = const MaintenanceSaveState(status: MaintenanceSaveStatus.loading);
    try {
      await _saveUseCase.execute(
        vehicleId: vehicleId,
        type: type,
        title: title,
        date: date,
        mileageAtService: mileageAtService,
        cost: cost,
        notes: notes,
        nextServiceMileage: nextServiceMileage,
        nextServiceDate: nextServiceDate,
        workshop: workshop,
        existingId: existingId,
      );
      state = const MaintenanceSaveState(status: MaintenanceSaveStatus.success);
      return true;
    } catch (e) {
      state = MaintenanceSaveState(
        status: MaintenanceSaveStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> deleteRecord(String recordId) async {
    await _deleteUseCase.execute(recordId);
  }

  void reset() => state = const MaintenanceSaveState();
}

final maintenanceNotifierProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceSaveState>((ref) {
  return MaintenanceNotifier(
    ref.read(saveMaintenanceRecordUseCaseProvider),
    ref.read(deleteMaintenanceRecordUseCaseProvider),
  );
});
