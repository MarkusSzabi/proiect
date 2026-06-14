import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/trip.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDataSource {
  Stream<List<TripModel>> watchTrips(String vehicleId);
  Future<TripModel> saveTrip(TripModel model);
  Future<void> deleteTrip(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  TripRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('trips');

  @override
  Stream<List<TripModel>> watchTrips(String vehicleId) {
    return _col
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TripModel.fromFirestore).toList());
  }

  @override
  Future<TripModel> saveTrip(TripModel model) async {
    final id = model.id.isEmpty ? const Uuid().v4() : model.id;
    final data = TripModel.fromTrip(model.copyWith(id: id)).toFirestore();
    await _col.doc(id).set(data, SetOptions(merge: true));
    final doc = await _col.doc(id).get();
    return TripModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _col.doc(tripId).delete();
  }
}