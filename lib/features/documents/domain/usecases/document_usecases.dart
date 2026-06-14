import 'package:uuid/uuid.dart';
import '../entities/vehicle_document.dart';
import '../repositories/document_repository.dart';

class GetDocumentsUseCase {
  const GetDocumentsUseCase(this._repository);
  final DocumentRepository _repository;

  Future<List<VehicleDocument>> execute(String vehicleId) =>
      _repository.getDocuments(vehicleId);
}

class SaveDocumentUseCase {
  const SaveDocumentUseCase(this._repository);
  final DocumentRepository _repository;

  Future<VehicleDocument> execute({
    required String vehicleId,
    required DocumentType type,
    required DateTime expiryDate,
    int reminderDaysBefore = 30,
    String? notes,
    String? existingId,
  }) async {
    final doc = VehicleDocument(
      id: existingId ?? const Uuid().v4(),
      vehicleId: vehicleId,
      type: type,
      expiryDate: expiryDate,
      reminderDaysBefore: reminderDaysBefore,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );
    return _repository.saveDocument(doc);
  }
}

class DeleteDocumentUseCase {
  const DeleteDocumentUseCase(this._repository);
  final DocumentRepository _repository;

  Future<void> execute(String documentId) =>
      _repository.deleteDocument(documentId);
}