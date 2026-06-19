import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/usecases/trip_usecases.dart';

final tripDataSourceProvider = Provider<TripRemoteDataSource>((ref) {
  return TripRemoteDataSourceImpl(ref.read(firestoreProvider));
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(ref.read(tripDataSourceProvider));
});

final getTripsUseCaseProvider = Provider<GetTripsUseCase>((ref) {
  return GetTripsUseCase(ref.read(tripRepositoryProvider));
});

final startTripUseCaseProvider = Provider<StartTripUseCase>((ref) {
  return StartTripUseCase(ref.read(tripRepositoryProvider));
});

final updateTripUseCaseProvider = Provider<UpdateTripUseCase>((ref) {
  return UpdateTripUseCase(ref.read(tripRepositoryProvider));
});

final deleteTripUseCaseProvider = Provider<DeleteTripUseCase>((ref) {
  return DeleteTripUseCase(ref.read(tripRepositoryProvider));
});

final tripsStreamProvider = StreamProvider<List<Trip>>((ref) {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return Stream.value([]);
  return ref.read(getTripsUseCaseProvider).execute(activeVehicle.id);
});

enum TripStatus {
  idle,
  requesting,
  gpsFailure,
  active,
  activeManual,
  paused,
  saving,
}

class ActiveTripState {
  const ActiveTripState({
    this.status = TripStatus.idle,
    this.currentTrip,
    this.distanceKm = 0,
    this.errorMessage,
    this.elapsedSeconds = 0,
    this.startLocation,
    this.endLocation,
  });

  final TripStatus status;
  final Trip? currentTrip;
  final double distanceKm;
  final String? errorMessage;
  final int elapsedSeconds;
  final String? startLocation;
  final String? endLocation;

  bool get isTracking =>
      status == TripStatus.active || status == TripStatus.activeManual;
  bool get hasError => errorMessage != null;

  String get elapsedDisplay {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get distanceDisplay => '${distanceKm.toStringAsFixed(2)} km';

  ActiveTripState copyWith({
    TripStatus? status,
    Trip? currentTrip,
    double? distanceKm,
    String? errorMessage,
    int? elapsedSeconds,
    String? startLocation,
    String? endLocation,
  }) {
    return ActiveTripState(
      status: status ?? this.status,
      currentTrip: currentTrip ?? this.currentTrip,
      distanceKm: distanceKm ?? this.distanceKm,
      errorMessage: errorMessage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
    );
  }
}

class TripNotifier extends StateNotifier<ActiveTripState> {
  TripNotifier(this._ref) : super(const ActiveTripState());

  final Ref _ref;
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  Position? _lastPosition;

  Future<bool> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> startTrip() async {
    state = state.copyWith(status: TripStatus.requesting, errorMessage: null);

    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        status: TripStatus.gpsFailure,
        errorMessage: 'Location permission denied.',
      );
      return;
    }

    final vehicle = _ref.read(activeVehicleProvider);
    final user = _ref.read(authStateProvider).valueOrNull;

    if (vehicle == null || user == null) {
      state = state.copyWith(
        status: TripStatus.idle,
        errorMessage: 'No active vehicle found.',
      );
      return;
    }

    Position? startPos;
    String? startLocationName;
    try {
      startPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
      startLocationName =
          '${startPos.latitude.toStringAsFixed(4)}, ${startPos.longitude.toStringAsFixed(4)}';
    } catch (_) {
      state = state.copyWith(
        status: TripStatus.gpsFailure,
        errorMessage: 'GPS signal weak. Use manual mode or try again.',
      );
      return;
    }

    final trip = await _ref.read(startTripUseCaseProvider).execute(
          vehicleId: vehicle.id,
          userId: user.uid,
          startLocationName: startLocationName,
        );

    _lastPosition = startPos;
    _startTracking(trip, TripStatus.active, startLocationName);
  }

  Future<void> startTripManual({
    required String startLocation,
    String? endLocation,
  }) async {
    final vehicle = _ref.read(activeVehicleProvider);
    final user = _ref.read(authStateProvider).valueOrNull;

    if (vehicle == null || user == null) {
      state = state.copyWith(
        status: TripStatus.idle,
        errorMessage: 'No active vehicle found.',
      );
      return;
    }

    state = state.copyWith(status: TripStatus.requesting, errorMessage: null);

    final trip = await _ref.read(startTripUseCaseProvider).execute(
          vehicleId: vehicle.id,
          userId: user.uid,
          startLocationName: startLocation,
        );

    _startTracking(
      trip,
      TripStatus.activeManual,
      startLocation,
      endLocation: endLocation,
    );

    _tryGpsInBackground();
  }

  void _startTracking(
    Trip trip,
    TripStatus status,
    String? startLocation, {
    String? endLocation,
  }) {
    state = ActiveTripState(
      status: status,
      currentTrip: trip,
      distanceKm: 0,
      elapsedSeconds: 0,
      startLocation: startLocation,
      endLocation: endLocation,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });

    if (status == TripStatus.active) {
      _startGpsStream();
    }
  }

  void _startGpsStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      final speedKmh = position.speed * 3.6;
      if (_lastPosition != null && speedKmh >= 5) {
        final distanceM = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        state = state.copyWith(
          distanceKm: state.distanceKm + distanceM / 1000,
        );
      }
      if (speedKmh >= 5) _lastPosition = position;
    });
  }

  void _tryGpsInBackground() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      if (state.status != TripStatus.activeManual) return;
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
        if (!mounted) return;
        if (state.status == TripStatus.activeManual) {
          _lastPosition = pos;
          state = state.copyWith(status: TripStatus.active);
          _startGpsStream();
        }
      } catch (_) {}
    });
  }

  Future<void> stopTrip({
    String? endLocation,
    double? manualDistanceKm,
  }) async {
    if (state.currentTrip == null) return;

    state = state.copyWith(status: TripStatus.saving);

    _positionSub?.cancel();
    _timer?.cancel();
    _positionSub = null;
    _timer = null;

    final finalDistance = (manualDistanceKm != null && manualDistanceKm > 0)
        ? manualDistanceKm
        : state.distanceKm;

    final endTime = DateTime.now();

    final updatedTrip = state.currentTrip!.copyWith(
      endTime: endTime,
      distanceKm: finalDistance,
      isActive: false,
      endLocationName: endLocation ?? state.endLocation,
    );

    await _ref.read(updateTripUseCaseProvider).execute(updatedTrip);

    if (finalDistance > 0) {
      final vehicle = _ref.read(activeVehicleProvider);
      if (vehicle != null) {
        await _ref
            .read(vehicleRepositoryProvider)
            .updateMileage(vehicle.id, finalDistance);
      }
    }

    state = const ActiveTripState(status: TripStatus.idle);
  }

  Future<void> deleteTrip(String tripId) async {
    await _ref.read(deleteTripUseCaseProvider).execute(tripId);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final tripNotifierProvider =
    StateNotifierProvider<TripNotifier, ActiveTripState>(
  (ref) => TripNotifier(ref),
);

final activeTripProvider = tripNotifierProvider;
