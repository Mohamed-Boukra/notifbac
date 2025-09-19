import 'package:flutter/material.dart';
import 'package:notibac/models/event.dart';
import 'package:notibac/pages/home.dart';
import 'services/database_service.dart';
import 'dart:math';
import 'package:notibac/pages/popupsSettingsPage.dart';
import 'package:notibac/pages/ListsPage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;//just to check ui in browser
import 'package:flutter_local_notifications/flutter_local_notifications.dart';//this is from old testing 
import 'services/notification_service.dart';//this is from old testing 
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart'; 
import 'dart:async';

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWidget(),
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("DEBUG: Workmanager task started.");
    if (task == "random-event-task") {
      print("DEBUG: Task is 'random-event-task'.");
      
      final selectedLists = await DatabaseService.getSelectedLists();
      final List<Event> allEvents = [];
      for (var listId in selectedLists) {
        final events = await DatabaseService.getEventsByListId(int.parse(listId));
        allEvents.addAll(events);
      }
      if (allEvents.isEmpty) {
        print("DEBUG: No events to show.");
        return Future.value(true);
      }
      final random = Random();
      final randomEvent = allEvents[random.nextInt(allEvents.length)];
      print("DEBUG: Random event selected: ${randomEvent.title}");

      try {
        await FlutterOverlayWindow.showOverlay(
          alignment: OverlayAlignment.topLeft,
          height: 100,
          width: 300,
          overlayTitle: "Event",
          overlayContent: 'date:${randomEvent.date}|event:${randomEvent.title}',
          enableDrag: true,
        );
        print("DEBUG: Successfully called showOverlay.");
      } catch (e) {
        print("DEBUG: Error showing overlay: $e");
      }
    }
    print("DEBUG: Workmanager task finished.");
    return Future.value(true);
  });
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Request SYSTEM_ALERT_WINDOW permission on Android
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
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

// The OverlayWidget class to be placed in your main.dart file

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});
  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  String? date;
  String? event;
  bool showDate = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Use the listener to receive data from the background task
    FlutterOverlayWindow.overlayListener.listen((event) {
      final parts = event.toString().split("|");
      if (parts.length == 2) {
        date = parts[0].replaceAll("date:", "");
        this.event = parts[1].replaceAll("event:", "");
        setState(() {});
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), () {
      FlutterOverlayWindow.closeOverlay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          showDate = !showDate;
          if (!showDate) {
            _startTimer();
          }
        });
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showDate ? "Date:" : "Event:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    showDate ? (date ?? 'Loading...') : (event ?? 'Loading...'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}