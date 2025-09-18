import 'package:flutter/material.dart';
import 'package:notibac/pages/home.dart';
import 'package:notibac/pages/popupsSettingsPage.dart';
import 'package:notibac/pages/ListsPage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('DEBUG: Background task triggered! Task ID: $task');
    if (task == "random-event-task") {
      await NotificationService.initialize();
      await NotificationService.showRandomEventNotification();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (!kIsWeb) {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    } catch (e) {
      print("Workmanager initialization failed: $e");
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
