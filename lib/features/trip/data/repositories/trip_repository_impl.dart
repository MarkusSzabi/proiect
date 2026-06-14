import 'package:uuid/uuid.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  const TripRepositoryImpl(this._dataSource);
  final TripRemoteDataSource _dataSource;

  @override
  Stream<List<Trip>> watchTrips(String vehicleId) =>
      _dataSource.watchTrips(vehicleId);

  @override
  Future<Trip> startTrip({
    required String vehicleId,
    required String userId,
    String? startLocationName,
  }) async {
    final trip = TripModel(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      userId: userId,
      startTime: DateTime.now(),
      startLocationName: startLocationName,
      distanceKm: 0,
      isActive: true,
      createdAt: DateTime.now(),
    );
    return _dataSource.saveTrip(trip);
  }

  @override
  Future<Trip> updateTrip(Trip trip) =>
      _dataSource.saveTrip(TripModel.fromTrip(trip));

  @override
  Future<void> deleteTrip(String tripId) => _dataSource.deleteTrip(tripId);
}