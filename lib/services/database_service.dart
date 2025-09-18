import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/event.dart';
import '../models/event_list.dart';

class DatabaseService {
  static const String _listsKey = 'event_lists';
  static const String _eventsKey = 'events';
  static const String _nextIdKey = 'next_id';
  static const String _selectedListsKey = 'selected_lists';

  static int _nextId = 1;

  // Initialize the service and load next ID
  static Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _nextId = prefs.getInt(_nextIdKey) ?? 1;
  }

  // Get next available ID
  static Future<int> _getNextId() async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    final id = _nextId++;
    await prefs.setInt(_nextIdKey, _nextId);
    return id;
  }

  // Initialize default data if not exists
  static Future<void> _initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if data already exists
    if (prefs.containsKey(_listsKey) || prefs.containsKey(_selectedListsKey)) {
      return;
    }

    print('DEBUG: Initializing default data...');
    
    // Create default lists
    final defaultLists = [
      EventList(
        id: 1,
        name: 'تواريخ الفصل الأول',
        description: 'أحداث الحرب العالمية الأولى والثانية',
        isEnabled: true,
        isPredefined: true,
      ),
      EventList(
        id: 2,
        name: 'تواريخ الفصل الثاني',
        description: 'أحداث ما بين الحربين والحرب العالمية الثانية',
        isEnabled: false,
        isPredefined: true,
      ),
      EventList(
        id: 3,
        name: 'تواريخ الفصل الثالث',
        description: 'أحداث الحرب الباردة وما بعدها',
        isEnabled: false,
        isPredefined: true,
      ),
    ];

    // Create default events
    final defaultEvents = [
      // First semester events
      Event(
        id: 1,
        title: 'اندلاع الحرب العالمية الأولى',
        date: '28-07-1914',
        listId: 1,
      ),
      Event(
        id: 2,
        title: 'تأسيس عصبة الأمم',
        date: '10-01-1920',
        listId: 1,
      ),
      Event(
        id: 3,
        title: 'انتهاء الحرب العالمية الثانية',
        date: '02-09-1945',
        listId: 1,
      ),
      // Second semester events
      Event(
        id: 4,
        title: 'ثورة أكتوبر الروسية',
        date: '07-11-1917',
        listId: 2,
      ),
      Event(
        id: 5,
        title: 'معاهدة فرساي',
        date: '28-06-1919',
        listId: 2,
      ),
      Event(
        id: 6,
        title: 'أزمة الكساد الكبير',
        date: '29-10-1929',
        listId: 2,
      ),
      Event(
        id: 7,
        title: 'صعود هتلر للسلطة',
        date: '30-01-1933',
        listId: 2,
      ),
      Event(
        id: 8,
        title: 'غزو بولندا',
        date: '01-09-1939',
        listId: 2,
      ),
      // Third semester events
      Event(
        id: 9,
        title: 'الحرب الباردة',
        date: '12-03-1947',
        listId: 3,
      ),
      Event(
        id: 10,
        title: 'تأسيس الأمم المتحدة',
        date: '24-10-1945',
        listId: 3,
      ),
      Event(
        id: 11,
        title: 'أزمة الصواريخ الكوبية',
        date: '14-10-1962',
        listId: 3,
      ),
      Event(
        id: 12,
        title: 'سقوط جدار برلين',
        date: '09-11-1989',
        listId: 3,
      ),
      Event(
        id: 13,
        title: 'انهيار الاتحاد السوفيتي',
        date: '26-12-1991',
        listId: 3,
      ),
    ];

    // Save to SharedPreferences
    await _saveLists(defaultLists);
    await _saveEvents(defaultEvents);
    
    // Set next ID
    await prefs.setInt(_nextIdKey, 14);
    _nextId = 14;
    
    print('DEBUG: Default data initialized successfully');
  }

  // Save lists to SharedPreferences
  static Future<void> _saveLists(List<EventList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = lists.map((list) => list.toJson()).toList();
    await prefs.setString(_listsKey, jsonEncode(listsJson));
  }

  // Save events to SharedPreferences
  static Future<void> _saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => event.toJson()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsJson));
  }

  // Load lists from SharedPreferences
  static Future<List<EventList>> _loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = prefs.getString(_listsKey) ?? '[]';
    final List<dynamic> listsData = jsonDecode(listsJson);
    return listsData.map((data) => EventList.fromJson(data)).toList();
  }

  // Load events from SharedPreferences
  static Future<List<Event>> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey) ?? '[]';
    final List<dynamic> eventsData = jsonDecode(eventsJson);
    return eventsData.map((data) => Event.fromJson(data)).toList();
  }

  // ========== PUBLIC API ==========

  // Event List Operations
  static Future<List<EventList>> getAllLists() async {
    print('DEBUG: getAllLists called');
    await _initializeDefaults();
    final lists = await _loadLists();
    print('DEBUG: Found ${lists.length} lists');
    return lists;
  }

  static Future<List<String>> getSelectedLists() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedListsJson = prefs.getString(_selectedListsKey) ?? '[]';
    final List<dynamic> selectedListsData = jsonDecode(selectedListsJson);
    return selectedListsData.map((data) => data.toString()).toList();
  }

  static Future<void> saveSelectedLists(List<String> selectedLists) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedListsJson = jsonEncode(selectedLists);
    await prefs.setString(_selectedListsKey, selectedListsJson);
  }

  static Future<EventList?> getListById(int id) async {
    final lists = await _loadLists();
    try {
      return lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<int> insertList(EventList list) async {
    print('DEBUG: Inserting new list: ${list.name}');
    final lists = await _loadLists();
    final newId = await _getNextId();
    final newList = list.copyWith(id: newId);
    lists.add(newList);
    await _saveLists(lists);
    print('DEBUG: List inserted with ID: $newId');
    return newId;
  }

  static Future<int> updateList(EventList list) async {
    print('DEBUG: Updating list: ${list.name}');
    final lists = await _loadLists();
    final index = lists.indexWhere((l) => l.id == list.id);
    if (index != -1) {
      lists[index] = list;
      await _saveLists(lists);
      return 1;
    }
    return 0;
  }

  static Future<int> deleteList(int id) async {
    print('DEBUG: Deleting list with ID: $id');
    final lists = await _loadLists();
    lists.removeWhere((list) => list.id == id);
    await _saveLists(lists);
    
    // Also delete all events in this list
    final events = await _loadEvents();
    events.removeWhere((event) => event.listId == id);
    await _saveEvents(events);
    
    return 1;
  }

  // Event Operations
  static Future<List<Event>> getEventsByListId(int listId) async {
    print('DEBUG: Getting events for list ID: $listId');
    final events = await _loadEvents();
    final filteredEvents = events.where((event) => event.listId == listId).toList();
    print('DEBUG: Found ${filteredEvents.length} events for list $listId');
    return filteredEvents;
  }

  static Future<List<Event>> getAllEnabledEvents() async {
    final lists = await _loadLists();
    final enabledListIds = lists.where((list) => list.isEnabled).map((list) => list.id!).toList();
    final events = await _loadEvents();
    return events.where((event) => enabledListIds.contains(event.listId)).toList();
  }

  static Future<List<Event>> searchEvents(String query) async {
    final allEvents = await getAllEnabledEvents();
    return allEvents.where((event) =>
        event.title.toLowerCase().contains(query.toLowerCase()) ||
        event.date.contains(query)).toList();
  }

  static Future<Map<String, dynamic>> getPopupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('popup_settings') ?? '{}';
    return jsonDecode(settingsJson);
  }

  static Future<void> savePopupSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings);
    await prefs.setString('popup_settings', settingsJson);
  }

  static Future<Event?> getEventById(int id) async {
    final events = await _loadEvents();
    try {
      return events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<int> insertEvent(Event event) async {
    print('DEBUG: Inserting new event: ${event.title}');
    final events = await _loadEvents();
    final newId = await _getNextId();
    final newEvent = Event(id: newId, title: event.title, date: event.date, listId: event.listId, isCustom: event.isCustom,);
    events.add(newEvent);
    await _saveEvents(events);
    print('DEBUG: Event inserted with ID: $newId');
    return newId;
  }

  static Future<int> updateEvent(Event event) async {
    print('DEBUG: Updating event: ${event.title}');
    final events = await _loadEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await _saveEvents(events);
      return 1;
    }
    return 0;
  }

  static Future<int> deleteEvent(int id) async {
    print('DEBUG: Deleting event with ID: $id');
    final events = await _loadEvents();
    events.removeWhere((event) => event.id == id);
    await _saveEvents(events);
    return 1;
  }

  // Utility methods
  static Future<int> getEventCount(int listId) async {
    final events = await getEventsByListId(listId);
    return events.length;
  }

  static Future<void> resetListToDefault(int listId) async {
    print('DEBUG: Resetting list $listId to default');
    final events = await _loadEvents();
    events.removeWhere((event) => event.listId == listId && event.isCustom);
    await _saveEvents(events);
  }

  // Close database (no-op for SharedPreferences)
  static Future<void> close() async {
    print('DEBUG: Database closed');
  }

  // Reset database instance (no-op for SharedPreferences)
  static void resetInstance() {
    print('DEBUG: Database instance reset');
  }
}
