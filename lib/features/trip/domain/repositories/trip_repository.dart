import '../entities/trip.dart';

abstract class TripRepository {
  Stream<List<Trip>> watchTrips(String vehicleId);
  Future<Trip> startTrip({
    required String vehicleId,
    required String userId,
    String? startLocationName,
  });
  Future<Trip> updateTrip(Trip trip);
  Future<void> deleteTrip(String tripId);
}