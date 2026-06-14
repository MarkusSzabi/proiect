import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/documents/presentation/providers/document_provider.dart';
import '../../../features/maintenance/presentation/providers/maintenance_provider.dart';
import '../../../features/vehicle/presentation/providers/vehicle_provider.dart';
import 'notification_service.dart';

// ── Provider care declanseaza notificarile ────────────────

final notificationSchedulerProvider = Provider<void>((ref) {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return;

  // Watch documente
  ref.watch(documentsProvider).whenData((docs) {
    NotificationService.instance.scheduleDocumentNotifications(docs);
  });

  // Watch maintenance
  ref.watch(maintenanceRecordsProvider).whenData((records) {
    NotificationService.instance.scheduleMaintenanceNotifications(records);
  });
});

// ── State pentru notificari in-app ────────────────────────

class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  InAppNotification copyWith({bool? isRead}) {
    return InAppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType { document, maintenance, trip }

class NotificationNotifier extends StateNotifier<List<InAppNotification>> {
  NotificationNotifier() : super([]);

  void addNotification(InAppNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state =
        state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void clearAll() {
    state = [];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, List<InAppNotification>>(
  (ref) => NotificationNotifier(),
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationNotifierProvider).where((n) => !n.isRead).length;
});
