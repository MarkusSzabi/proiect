import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../features/documents/domain/entities/vehicle_document.dart';
import '../../../features/maintenance/domain/entities/maintenance_record.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ── Channel IDs ───────────────────────────────────────
  static const _docChannel = 'document_reminders';
  static const _maintChannel = 'maintenance_reminders';

  // ── Notification ID ranges ────────────────────────────
  // Documents: 1000 - 1999 (30-day), 2000-2999 (7-day daily)
  // Maintenance: 3000 - 3999

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );

    // Creeaza channels Android
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _docChannel,
            'Document Reminders',
            description: 'Reminders for expiring vehicle documents',
            importance: Importance.high,
          ),
        );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _maintChannel,
            'Maintenance Reminders',
            description: 'Reminders for vehicle maintenance',
            importance: Importance.high,
          ),
        );
  }

  // ── Request permissions ───────────────────────────────

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ── Schedule document notifications ──────────────────

  Future<void> scheduleDocumentNotifications(
      List<VehicleDocument> documents) async {
    // Sterge toate notificarile vechi de documente
    for (int i = 1000; i < 3000; i++) {
      await _plugin.cancel(i);
    }

    int idCounter = 1000;

    for (final doc in documents) {
      if (doc.isExpired) continue;

      final daysLeft = doc.daysUntilExpiry;
      final docName = doc.type.displayName;

      // ── Notificare la 30 de zile ──────────────────────
      if (daysLeft > 30) {
        final notifyAt = doc.expiryDate.subtract(const Duration(days: 30));
        await _scheduleNotification(
          id: idCounter++,
          title: '📋 Document Expiring Soon',
          body: '$docName expires in 30 days. Renew it before it\'s too late.',
          scheduledDate: notifyAt,
          channelId: _docChannel,
          channelName: 'Document Reminders',
        );
      } else if (daysLeft == 30) {
        // Trimite imediat daca azi e exact 30 de zile
        await _showNotification(
          id: idCounter++,
          title: '📋 Document Expiring Soon',
          body: '$docName expires in 30 days.',
          channelId: _docChannel,
          channelName: 'Document Reminders',
        );
      }

      // ── Notificari zilnice in ultima saptamana ─────────
      if (daysLeft <= 7 && daysLeft > 0) {
        // Notificare imediata pentru zilele deja in range
        await _showNotification(
          id: idCounter++,
          title:
              '⚠️ $docName Expires in $daysLeft Day${daysLeft == 1 ? '' : 's'}!',
          body: daysLeft == 1
              ? '$docName expires TOMORROW! Renew immediately.'
              : '$docName expires in $daysLeft days. Take action now.',
          channelId: _docChannel,
          channelName: 'Document Reminders',
        );

        // Programeaza si pentru zilele ramase
        for (int day = daysLeft - 1; day >= 1; day--) {
          final notifyAt = doc.expiryDate.subtract(Duration(days: day));
          // Notifica la ora 9:00 dimineata
          final scheduledDateTime = DateTime(
            notifyAt.year,
            notifyAt.month,
            notifyAt.day,
            9,
            0,
          );
          if (scheduledDateTime.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id: idCounter++,
              title: '⚠️ $docName Expires in $day Day${day == 1 ? '' : 's'}!',
              body: day == 1
                  ? '$docName expires TOMORROW! Renew immediately.'
                  : '$docName expires in $day days. Renew it now.',
              scheduledDate: scheduledDateTime,
              channelId: _docChannel,
              channelName: 'Document Reminders',
            );
          }
        }
      } else if (daysLeft > 7) {
        // Programeaza notificarile zilnice pentru saptamana dinainte de expirare
        for (int day = 7; day >= 1; day--) {
          final notifyAt = doc.expiryDate.subtract(Duration(days: day));
          final scheduledDateTime = DateTime(
            notifyAt.year,
            notifyAt.month,
            notifyAt.day,
            9,
            0,
          );
          if (scheduledDateTime.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id: idCounter++,
              title: '⚠️ $docName Expires in $day Day${day == 1 ? '' : 's'}!',
              body: day == 1
                  ? '$docName expires TOMORROW! Renew immediately.'
                  : '$docName expires in $day days. Renew it now.',
              scheduledDate: scheduledDateTime,
              channelId: _docChannel,
              channelName: 'Document Reminders',
            );
          }
        }
      }

      if (idCounter >= 3000) break; // Safety limit
    }
  }

  // ── Schedule maintenance notifications ────────────────

  Future<void> scheduleMaintenanceNotifications(
      List<MaintenanceRecord> records) async {
    // Sterge toate notificarile vechi de mentenanta
    for (int i = 3000; i < 4000; i++) {
      await _plugin.cancel(i);
    }

    int idCounter = 3000;

    for (final record in records) {
      if (record.nextServiceDate == null) continue;
      if (record.isOverdue) continue;

      final daysLeft =
          record.nextServiceDate!.difference(DateTime.now()).inDays;
      final title = record.title;

      // Notificare la 30 de zile
      if (daysLeft > 30) {
        final notifyAt =
            record.nextServiceDate!.subtract(const Duration(days: 30));
        await _scheduleNotification(
          id: idCounter++,
          title: '🔧 Maintenance Due Soon',
          body: '$title is due in 30 days.',
          scheduledDate: notifyAt,
          channelId: _maintChannel,
          channelName: 'Maintenance Reminders',
        );
      } else if (daysLeft <= 30 && daysLeft > 7) {
        await _showNotification(
          id: idCounter++,
          title: '🔧 Maintenance Due in $daysLeft Days',
          body: '$title service is coming up. Schedule an appointment.',
          channelId: _maintChannel,
          channelName: 'Maintenance Reminders',
        );
      }

      // Notificari zilnice in ultima saptamana
      if (daysLeft <= 7 && daysLeft > 0) {
        await _showNotification(
          id: idCounter++,
          title: '🔧 $title Due in $daysLeft Day${daysLeft == 1 ? '' : 's'}!',
          body: daysLeft == 1
              ? '$title is due TOMORROW!'
              : '$title service due in $daysLeft days.',
          channelId: _maintChannel,
          channelName: 'Maintenance Reminders',
        );
      }

      if (idCounter >= 4000) break;
    }
  }

  // ── Show immediate notification ───────────────────────

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Schedule future notification ──────────────────────

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Show immediate maintenance reminder ───────────────

  Future<void> showMaintenanceReminder({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _showNotification(
      id: id,
      title: title,
      body: body,
      channelId: _maintChannel,
      channelName: 'Maintenance Reminders',
    );
  }

  // ── Cancel all ────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Check pending ─────────────────────────────────────

  Future<int> getPendingCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }
}
