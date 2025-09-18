import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/event.dart';

class EventsPage extends StatefulWidget {
  final String listTitle;
  final int listId;

  const EventsPage({
    super.key,
    required this.listTitle,
    required this.listId,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  TextEditingController searchController = TextEditingController();
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      print('DEBUG: Loading events for list ${widget.listId}...');
      final events = await DatabaseService.getEventsByListId(widget.listId);
      setState(() {
        allEvents = events;
        filteredEvents = events;
        isLoading = false;
      });
      print('DEBUG: Loaded ${events.length} events');
    } catch (e) {
      print('DEBUG: Error loading events: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل الأحداث: $e';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEvents = allEvents;
      } else {
        filteredEvents = allEvents.where((event) {
          return event.title.toLowerCase().contains(query.toLowerCase()) ||
                 event.date.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _addEvent() async {
    final titleController = TextEditingController();
    final dateController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة حدث جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الحدث',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'التاريخ (DD-MM-YYYY)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                 
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && dateController.text.isNotEmpty) {
                    final newEvent = Event(
                      title: titleController.text,
                      date: dateController.text,
                      listId: widget.listId,
                      isCustom: true,
                    );

                    await DatabaseService.insertEvent(newEvent);
                    await _loadEvents();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الحدث بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى ملء العنوان والتاريخ'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteEvent(Event event) async {
    try {
      print('DEBUG: Deleting event: ${event.title}');
      await DatabaseService.deleteEvent(event.id!);
      await _loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الحدث بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('DEBUG: Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في حذف الحدث'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Orange Header
              Container(
                height: screenHeight * 0.08,
                width: double.infinity,
                color: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Stack(
                  children: [
                    // Centered title
                    Center(
                      child: Text(
                        widget.listTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Back button positioned on the right
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: screenHeight * 0.035,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        height: screenHeight * 0.06,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: searchController,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: Colors.grey[700],
                          ),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن حدث أو تاريخ',
                            hintStyle: TextStyle(
                              fontSize: screenHeight * 0.018,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: _filterEvents,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Add event button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: screenHeight * 0.06,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenHeight * 0.03),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextButton(
                            onPressed: _addEvent,
                            child: Text(
                              'إضافة حدث',
                              style: TextStyle(
                                fontSize: screenHeight * 0.018,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Events list
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              )
                            : errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: screenHeight * 0.08,
                                          color: Colors.red[400],
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        Text(
                                          'خطأ في تحميل الأحداث',
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.016,
                                            color: Colors.red[500],
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              errorMessage = null;
                                            });
                                            _loadEvents();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[600],
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text('إعادة المحاولة'),
                                        ),
                                      ],
                                    ),
                                  )
                                : filteredEvents.isEmpty
                                    ? Center(
                                        child: Text(
                                          searchController.text.isNotEmpty
                                              ? 'لا توجد أحداث تطابق البحث'
                                              : 'لا توجد أحداث في هذه القائمة',
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.02,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredEvents.length,
                                        itemBuilder: (context, index) {
                                          final event = filteredEvents[index];
                                          return _buildEventCard(event, screenHeight, screenWidth);
                                        },
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, double screenHeight, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.015),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title
              Text(
                event.title,
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // Event date
              Text(
                event.date,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (event.isCustom)
            GestureDetector(
              onTap: () {
                _deleteEvent(event);
              },
              child: Container(
                padding: EdgeInsets.all(screenHeight * 0.008),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child:  Icon(
                  Icons.delete,
                  color: Colors.red[600],
                  size: screenHeight * 0.02,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
