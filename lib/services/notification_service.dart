// services/notification_service.dart

import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/event.dart';
import 'database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

    static FlutterLocalNotificationsPlugin get notificationsPlugin => _notificationsPlugin;

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> showRandomEventNotification() async {
    final selectedLists = await DatabaseService.getSelectedLists();
    final List<Event> allEvents = [];
    print('DEBUG: Attempting to fetch events from lists: $selectedLists');
    for (var listId in selectedLists) {
      final events = await DatabaseService.getEventsByListId(int.parse(listId));
      allEvents.addAll(events);
    }

    if (allEvents.isEmpty) {
      print('No events to show notifications for.');
      return;
    }

    // Select a random event
    final random = Random();
    final randomEvent = allEvents[random.nextInt(allEvents.length)];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'random_event_channel', // Channel ID
      'Random Events', // Channel name
      channelDescription: 'Random history events and dates',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0, // Notification ID
      randomEvent.date,
      randomEvent.title,
      platformChannelSpecifics,
      payload: '{"date": "${randomEvent.date}", "title": "${randomEvent.title}"}',
    );
  }
}