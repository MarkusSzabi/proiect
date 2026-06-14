import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  static const _keyPrefix = 'documents_';

  String _key(String vehicleId) => '$_keyPrefix$vehicleId';

  @override
  Future<List<VehicleDocument>> getDocuments(String vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(vehicleId)) ?? [];
    return raw
        .map((s) => DocumentModel.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  }

  @override
  Future<VehicleDocument> saveDocument(VehicleDocument document) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(document.vehicleId);
    final raw = prefs.getStringList(key) ?? [];

    final docs = raw
        .map((s) => DocumentModel.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();

    // Inlocuieste daca exista, altfel adauga
    final idx = docs.indexWhere((d) => d.id == document.id);
    final model = DocumentModel.fromDocument(document);
    if (idx >= 0) {
      docs[idx] = model;
    } else {
      docs.add(model);
    }

    await prefs.setStringList(
      key,
      docs.map((d) => jsonEncode(d.toJson())).toList(),
    );
    return document;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));

    for (final key in allKeys) {
      final raw = prefs.getStringList(key) ?? [];
      final docs = raw
          .map((s) => DocumentModel.fromJson(
              jsonDecode(s) as Map<String, dynamic>))
          .toList();
      final filtered = docs.where((d) => d.id != documentId).toList();
      if (filtered.length != docs.length) {
        await prefs.setStringList(
          key,
          filtered.map((d) => jsonEncode(d.toJson())).toList(),
        );
        break;
      }
    }
  }
}