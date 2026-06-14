import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.vehicleId,
    required super.userId,
    required super.startTime,
    super.endTime,
    super.startLocationName,
    super.endLocationName,
    super.distanceKm,
    super.isActive,
    super.category,
    required super.createdAt,
  });

  factory TripModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TripModel(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      userId: data['userId'] ?? '',
      startTime:
          (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      startLocationName: data['startLocationName'],
      endLocationName: data['endLocationName'],
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      isActive: data['isActive'] ?? false,
      category: TripCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TripCategory.personal,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TripModel.fromTrip(Trip t) => TripModel(
        id: t.id,
        vehicleId: t.vehicleId,
        userId: t.userId,
        startTime: t.startTime,
        endTime: t.endTime,
        startLocationName: t.startLocationName,
        endLocationName: t.endLocationName,
        distanceKm: t.distanceKm,
        isActive: t.isActive,
        category: t.category,
        createdAt: t.createdAt,
      );

  Map<String, dynamic> toFirestore() => {
        'vehicleId': vehicleId,
        'userId': userId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
        'startLocationName': startLocationName,
        'endLocationName': endLocationName,
        'distanceKm': distanceKm,
        'isActive': isActive,
        'category': category.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}