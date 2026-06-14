import '../entities/vehicle_document.dart';

abstract class DocumentRepository {
  Future<List<VehicleDocument>> getDocuments(String vehicleId);
  Future<VehicleDocument> saveDocument(VehicleDocument document);
  Future<void> deleteDocument(String documentId);
}