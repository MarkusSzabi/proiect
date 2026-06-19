import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Stream<List<VehicleModel>> watchVehicles(String userId);
  Future<VehicleModel> saveVehicle(VehicleModel model);
  Future<void> updateMileage(String vehicleId, double additionalKm);
  Future<void> setActiveVehicle(String userId, String vehicleId);
  Future<void> deleteVehicle(String vehicleId);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  VehicleRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      _firestore.collection('vehicles');

  @override
  Stream<List<VehicleModel>> watchVehicles(String userId) {
    return _vehicles
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(VehicleModel.fromFirestore).toList());
  }

  @override
  Future<VehicleModel> saveVehicle(VehicleModel model) async {
    final ref = _vehicles.doc(model.id);
    final doc = await ref.get();
    final data = model.toFirestore();

    if (doc.exists) {
      await ref.update(data);
    } else {
      await ref.set(data);
    }

    final savedDoc = await ref.get();
    return VehicleModel.fromFirestore(savedDoc);
  }

  @override
  Future<void> updateMileage(String vehicleId, double additionalKm) async {
    await _vehicles.doc(vehicleId).update({
      'currentMileageKm': FieldValue.increment(additionalKm),
    });
  }

  @override
  Future<void> setActiveVehicle(String userId, String vehicleId) async {
    final batch = _firestore.batch();
    final allVehicles =
        await _vehicles.where('userId', isEqualTo: userId).get();

    for (final doc in allVehicles.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    batch.update(_vehicles.doc(vehicleId), {'isActive': true});
    await batch.commit();
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehicles.doc(vehicleId).delete();
  }
}
