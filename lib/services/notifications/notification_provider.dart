import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/documents/presentation/providers/document_provider.dart';
import '../../../features/maintenance/presentation/providers/maintenance_provider.dart';
import '../../../features/vehicle/presentation/providers/vehicle_provider.dart';
import 'notification_service.dart';

final notificationSchedulerProvider = Provider<void>((ref) {
  final activeVehicle = ref.watch(activeVehicleProvider);
  if (activeVehicle == null) return;

  ref.watch(documentsProvider).whenData((docs) {
    NotificationService.instance.scheduleDocumentNotifications(docs);
  });

  ref.watch(maintenanceRecordsProvider).whenData((records) {
    NotificationService.instance.scheduleMaintenanceNotifications(records);
  });
});

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory InAppNotification.fromJson(Map<String, dynamic> m) =>
      InAppNotification(
        id: m['id'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
        type: NotificationType.values.byName(m['type'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
        isRead: m['isRead'] as bool? ?? false,
      );
}

enum NotificationType { document, maintenance, trip }

class NotificationNotifier extends StateNotifier<List<InAppNotification>> {
  NotificationNotifier() : super([]) {
    _load();
  }

  static const _prefsKey = 'in_app_notifications';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        state = list
            .map((e) => InAppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKey, jsonEncode(state.map((n) => n.toJson()).toList()));
    } catch (_) {}
  }

  void addNotification(InAppNotification notification) {
    state = [notification, ...state];
    _save();
  }

  void markAsRead(String id) {
    state =
        state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    _save();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    _save();
  }

  void clearAll() {
    state = [];
    _save();
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
