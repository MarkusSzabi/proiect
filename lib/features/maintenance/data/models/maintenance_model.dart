import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/maintenance_record.dart';

class MaintenanceModel extends MaintenanceRecord {
  const MaintenanceModel({
    required super.id,
    required super.vehicleId,
    required super.type,
    required super.title,
    required super.date,
    required super.mileageAtService,
    super.cost,
    super.notes,
    super.nextServiceMileage,
    super.nextServiceDate,
    super.workshop,
    required super.createdAt,
  });

  factory MaintenanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MaintenanceModel(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MaintenanceType.other,
      ),
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mileageAtService: (data['mileageAtService'] as num?)?.toDouble() ?? 0,
      cost: (data['cost'] as num?)?.toDouble(),
      notes: data['notes'],
      nextServiceMileage: (data['nextServiceMileage'] as num?)?.toDouble(),
      nextServiceDate: (data['nextServiceDate'] as Timestamp?)?.toDate(),
      workshop: data['workshop'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MaintenanceModel.fromRecord(MaintenanceRecord r) => MaintenanceModel(
        id: r.id,
        vehicleId: r.vehicleId,
        type: r.type,
        title: r.title,
        date: r.date,
        mileageAtService: r.mileageAtService,
        cost: r.cost,
        notes: r.notes,
        nextServiceMileage: r.nextServiceMileage,
        nextServiceDate: r.nextServiceDate,
        workshop: r.workshop,
        createdAt: r.createdAt,
      );

  Map<String, dynamic> toFirestore() => {
        'vehicleId': vehicleId,
        'type': type.name,
        'title': title,
        'date': Timestamp.fromDate(date),
        'mileageAtService': mileageAtService,
        'cost': cost,
        'notes': notes,
        'nextServiceMileage': nextServiceMileage,
        'nextServiceDate': nextServiceDate != null
            ? Timestamp.fromDate(nextServiceDate!)
            : null,
        'workshop': workshop,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
