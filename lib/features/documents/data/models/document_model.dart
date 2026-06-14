import 'dart:convert';
import '../../domain/entities/vehicle_document.dart';

class DocumentModel extends VehicleDocument {
  const DocumentModel({
    required super.id,
    required super.vehicleId,
    required super.type,
    required super.expiryDate,
    super.reminderDaysBefore,
    super.notes,
    required super.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      reminderDaysBefore: (json['reminderDaysBefore'] as int?) ?? 30,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory DocumentModel.fromDocument(VehicleDocument d) => DocumentModel(
        id: d.id,
        vehicleId: d.vehicleId,
        type: d.type,
        expiryDate: d.expiryDate,
        reminderDaysBefore: d.reminderDaysBefore,
        notes: d.notes,
        createdAt: d.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'type': type.name,
        'expiryDate': expiryDate.toIso8601String(),
        'reminderDaysBefore': reminderDaysBefore,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());
  static DocumentModel fromJsonString(String s) =>
      DocumentModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}