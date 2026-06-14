import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_model.dart';

abstract class MaintenanceRemoteDataSource {
  Stream<List<MaintenanceModel>> watchRecords(String vehicleId);
  Future<MaintenanceModel> saveRecord(MaintenanceModel model);
  Future<void> deleteRecord(String recordId);
  Future<List<MaintenanceModel>> getUpcomingServices(String vehicleId);
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  MaintenanceRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('maintenance_records');

  @override
  Stream<List<MaintenanceModel>> watchRecords(String vehicleId) {
    return _col
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MaintenanceModel.fromFirestore).toList());
  }

  @override
  Future<MaintenanceModel> saveRecord(MaintenanceModel model) async {
    final data = model.toFirestore();
    await _col.doc(model.id).set(data, SetOptions(merge: true));
    final doc = await _col.doc(model.id).get();
    return MaintenanceModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    await _col.doc(recordId).delete();
  }

  @override
  Future<List<MaintenanceModel>> getUpcomingServices(String vehicleId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final future =
        Timestamp.fromDate(DateTime.now().add(const Duration(days: 60)));
    final snap = await _col
        .where('vehicleId', isEqualTo: vehicleId)
        .where('nextServiceDate', isGreaterThanOrEqualTo: now)
        .where('nextServiceDate', isLessThanOrEqualTo: future)
        .get();
    return snap.docs.map(MaintenanceModel.fromFirestore).toList();
  }
}
