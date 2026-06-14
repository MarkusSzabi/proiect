import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/vehicle_usecases.dart';

// ── Infrastructure ────────────────────────────────────────

final vehicleDataSourceProvider = Provider<VehicleRemoteDataSource>((ref) {
  return VehicleRemoteDataSourceImpl(ref.read(firestoreProvider));
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.read(vehicleDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────

final saveVehicleUseCaseProvider = Provider<SaveVehicleUseCase>((ref) {
  return SaveVehicleUseCase(ref.read(vehicleRepositoryProvider));
});

final getVehiclesUseCaseProvider = Provider<GetVehiclesUseCase>((ref) {
  return GetVehiclesUseCase(ref.read(vehicleRepositoryProvider));
});

final setActiveVehicleUseCaseProvider = Provider<SetActiveVehicleUseCase>(
  (ref) => SetActiveVehicleUseCase(ref.read(vehicleRepositoryProvider)),
);

// ── Data streams ─────────────────────────────────────────

final vehiclesStreamProvider = StreamProvider<List<Vehicle>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.read(getVehiclesUseCaseProvider).execute(user.uid);
});

final activeVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesStreamProvider).valueOrNull ?? [];
  try {
    return vehicles.firstWhere((v) => v.isActive);
  } catch (_) {
    return vehicles.isNotEmpty ? vehicles.first : null;
  }
});

// ── Save state ────────────────────────────────────────────

enum VehicleSaveStatus { initial, loading, success, error }

class VehicleSaveState {
  const VehicleSaveState({
    this.status = VehicleSaveStatus.initial,
    this.errorMessage,
  });
  final VehicleSaveStatus status;
  final String? errorMessage;

  bool get isLoading => status == VehicleSaveStatus.loading;
}

class VehicleNotifier extends StateNotifier<VehicleSaveState> {
  VehicleNotifier(this._saveUseCase, this._setActiveUseCase, this._repository)
      : super(const VehicleSaveState());

  final SaveVehicleUseCase _saveUseCase;
  final SetActiveVehicleUseCase _setActiveUseCase;
  final VehicleRepository _repository;

  Future<bool> saveVehicle({
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
    state = const VehicleSaveState(status: VehicleSaveStatus.loading);
    try {
      final vehicle = await _saveUseCase.execute(
        userId: userId,
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        initialMileageKm: initialMileageKm,
        fuelType: fuelType,
        color: color,
        vin: vin,
        existingId: existingId,
      );
      await _setActiveUseCase.execute(userId, vehicle.id);
      state = const VehicleSaveState(status: VehicleSaveStatus.success);
      return true;
    } catch (e) {
      state = VehicleSaveState(
        status: VehicleSaveStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> setActive(String userId, String vehicleId) async {
    await _setActiveUseCase.execute(userId, vehicleId);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _repository.deleteVehicle(vehicleId);
  }

  void reset() => state = const VehicleSaveState();
}

final vehicleNotifierProvider =
    StateNotifierProvider<VehicleNotifier, VehicleSaveState>((ref) {
  return VehicleNotifier(
    ref.read(saveVehicleUseCaseProvider),
    ref.read(setActiveVehicleUseCaseProvider),
    ref.read(vehicleRepositoryProvider),
  );
});
