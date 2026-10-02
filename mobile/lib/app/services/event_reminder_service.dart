import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/studio_event.dart';

/// Schedules device notifications 7 days, 3 days, 1 day and 5 hours before
/// every upcoming event, so reminders arrive even when the app is closed.
class EventReminderService {
  EventReminderService._();

  static final EventReminderService instance = EventReminderService._();

  static const List<(Duration, String)> reminderOffsets = [
    (Duration(days: 7), 'in 7 days'),
    (Duration(days: 3), 'in 3 days'),
    (Duration(days: 1), 'tomorrow'),
    (Duration(hours: 5), 'in 5 hours'),
  ];

  // Android allows at most 500 pending alarms per app.
  static const int _maxScheduled = 400;
  static const int _idBase = 700000;

  static const _channel = AndroidNotificationDetails(
    'event_reminders',
    'Event reminders',
    channelDescription: 'Reminders before your upcoming shoots and events',
    importance: Importance.high,
    priority: Priority.high,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<bool>? _initFuture;
  Future<void> _queue = Future.value();
  Timer? _debounce;
  String? _lastSignature;
  bool _permissionRequested = false;

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> _ensureInitialized() => _initFuture ??= _initialize();

  Future<bool> _initialize() async {
    if (!_isSupported) return false;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Event reminders unavailable: $e');
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!await _ensureInitialized()) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.areNotificationsEnabled() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return (await ios.checkPermissions())?.isEnabled ?? false;
    return false;
  }

  Future<bool> requestPermission() async {
    if (!await _ensureInitialized()) return false;
    _permissionRequested = true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> openSettings() async {
    if (!await _ensureInitialized()) return;
    try {
      await _plugin.openAppNotificationSettings();
    } catch (_) {}
  }

  /// Replaces all scheduled reminders with ones for [events].
  /// Safe to call on every events change; calls are debounced.
  void syncEvents(List<StudioEvent> events) {
    if (!_isSupported) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _queue = _queue.then((_) => _reschedule(events)).catchError((Object e) {
        debugPrint('Failed to schedule event reminders: $e');
      });
    });
  }

  Future<void> _reschedule(List<StudioEvent> events) async {
    if (!await _ensureInitialized()) return;

    final now = DateTime.now();
    final reminders = <({StudioEvent event, DateTime start, DateTime at, String label})>[];
    for (final event in events) {
      if (event.status == EventStatus.completed ||
          event.status == EventStatus.cancelled) {
        continue;
      }
      final start = event.fullStartDateTime;
      if (!start.isAfter(now)) continue;
      for (final (offset, label) in reminderOffsets) {
        final at = start.subtract(offset);
        if (at.isAfter(now)) {
          reminders.add((event: event, start: start, at: at, label: label));
        }
      }
    }
    reminders.sort((a, b) => a.at.compareTo(b.at));
    final scheduled = reminders.take(_maxScheduled).toList();

    final signature = scheduled
        .map((r) =>
            '${r.event.id}|${r.at.millisecondsSinceEpoch}|${r.event.title}|'
            '${r.event.clientName}|${r.event.location}')
        .join(';');
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    if (scheduled.isNotEmpty && !_permissionRequested) {
      await requestPermission();
    }

    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= _idBase && request.id < _idBase + _maxScheduled) {
        await _plugin.cancel(id: request.id);
      }
    }

    for (var i = 0; i < scheduled.length; i++) {
      final r = scheduled[i];
      final type = r.event.eventType.trim().isEmpty ? 'Event' : r.event.eventType.trim();
      final title = '$type ${r.label}';
      final body = _body(r.event, r.start);
      await _plugin.zonedSchedule(
        id: _idBase + i,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        title: title,
        body: body,
        payload: r.event.id,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.channelId,
            _channel.channelName,
            channelDescription: _channel.channelDescription,
            importance: _channel.importance,
            priority: _channel.priority,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  String _body(StudioEvent event, DateTime start) {
    final parts = <String>[
      event.clientName.trim().isEmpty
          ? event.title
          : '${event.title} with ${event.clientName}',
      '${DateFormat('EEE, d MMM').format(start)} at ${event.startTime}',
      if (event.location.trim().isNotEmpty) event.location.trim(),
    ];
    return parts.join(' · ');
  }
}
