import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripsUseCase {
  const GetTripsUseCase(this._repository);
  final TripRepository _repository;

  Stream<List<Trip>> execute(String vehicleId) =>
      _repository.watchTrips(vehicleId);
}

class StartTripUseCase {
  const StartTripUseCase(this._repository);
  final TripRepository _repository;

  Future<Trip> execute({
    required String vehicleId,
    required String userId,
    String? startLocationName,
  }) =>
      _repository.startTrip(
        vehicleId: vehicleId,
        userId: userId,
        startLocationName: startLocationName,
      );
}

class UpdateTripUseCase {
  const UpdateTripUseCase(this._repository);
  final TripRepository _repository;

  Future<Trip> execute(Trip trip) => _repository.updateTrip(trip);
}

class DeleteTripUseCase {
  const DeleteTripUseCase(this._repository);
  final TripRepository _repository;

  Future<void> execute(String tripId) => _repository.deleteTrip(tripId);
}