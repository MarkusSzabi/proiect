import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/document_usecases.dart';

// ── Infrastructure ────────────────────────────────────────

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

// ── Use cases ─────────────────────────────────────────────

final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  return GetDocumentsUseCase(ref.read(documentRepositoryProvider));
});

final saveDocumentUseCaseProvider = Provider<SaveDocumentUseCase>((ref) {
  return SaveDocumentUseCase(ref.read(documentRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  return DeleteDocumentUseCase(ref.read(documentRepositoryProvider));
});

// ── Documents stream pentru vehiculul activ ───────────────

final documentsProvider =
    FutureProvider<List<VehicleDocument>>((ref) async {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return [];
  return ref
      .read(getDocumentsUseCaseProvider)
      .execute(activeVehicle.id);
});

// ── Save state ────────────────────────────────────────────

enum DocumentSaveStatus { initial, loading, success, error }

class DocumentSaveState {
  const DocumentSaveState({
    this.status = DocumentSaveStatus.initial,
    this.errorMessage,
  });
  final DocumentSaveStatus status;
  final String? errorMessage;

  bool get isLoading => status == DocumentSaveStatus.loading;
}

class DocumentNotifier extends StateNotifier<DocumentSaveState> {
  DocumentNotifier(this._saveUseCase, this._deleteUseCase)
      : super(const DocumentSaveState());

  final SaveDocumentUseCase _saveUseCase;
  final DeleteDocumentUseCase _deleteUseCase;

  Future<bool> saveDocument({
    required String vehicleId,
    required DocumentType type,
    required DateTime expiryDate,
    int reminderDaysBefore = 30,
    String? notes,
    String? existingId,
  }) async {
    state = const DocumentSaveState(status: DocumentSaveStatus.loading);
    try {
      await _saveUseCase.execute(
        vehicleId: vehicleId,
        type: type,
        expiryDate: expiryDate,
        reminderDaysBefore: reminderDaysBefore,
        notes: notes,
        existingId: existingId,
      );
      state = const DocumentSaveState(status: DocumentSaveStatus.success);
      return true;
    } catch (e) {
      state = DocumentSaveState(
        status: DocumentSaveStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    await _deleteUseCase.execute(documentId);
  }

  void reset() => state = const DocumentSaveState();
}

final documentNotifierProvider =
    StateNotifierProvider<DocumentNotifier, DocumentSaveState>((ref) {
  return DocumentNotifier(
    ref.read(saveDocumentUseCaseProvider),
    ref.read(deleteDocumentUseCaseProvider),
  );
});