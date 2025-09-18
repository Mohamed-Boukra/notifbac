import 'package:flutter/material.dart';
import 'EventsPage.dart';
import '../services/database_service.dart';
import '../models/event_list.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  TextEditingController listNameController = TextEditingController();
  List<String> selectedLists = []; // Will be updated from database
  List<EventList> allLists = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('DEBUG: Loading lists...');
      final lists = await DatabaseService.getAllLists();
      final selectedListsFromPrefs = await DatabaseService.getSelectedLists();
      setState(() {
        allLists = lists;
        // Load selected lists from SharedPreferences, or set first list as selected by default
        if (selectedListsFromPrefs.isNotEmpty) {
          selectedLists = selectedListsFromPrefs;
        } else if (lists.isNotEmpty) {
          selectedLists = [lists.first.id.toString()];
        } else {
          selectedLists = [];
        }
        isLoading = false;
      });
      print('DEBUG: Loaded ${lists.length} lists');
    } catch (e) {
      print('DEBUG: Error loading lists: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل القوائم: $e';
      });
    }
  }

  Future<void> _createNewList(String listName) async {
    try {
      // Check if there's already a custom list
      final customLists = allLists.where((list) => !list.isPredefined).toList();
      if (customLists.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يمكنك إضافة قائمة واحدة فقط'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('DEBUG: Creating new list: $listName');
      final newList = EventList(
        name: listName,
        description: 'قائمة مخصصة',
        isEnabled: true,
        isPredefined: false,
      );
      
      final id = await DatabaseService.insertList(newList);
      print('DEBUG: New list created with ID: $id');
      
      // Reload lists
      await _loadLists();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء القائمة: $listName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('DEBUG: Error creating new list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء القائمة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCustomList(EventList list) async {
    try {
      print('DEBUG: Deleting custom list: ${list.name}');
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف القائمة "${list.name}"؟\n\nسيتم حذف جميع الأحداث في هذه القائمة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await DatabaseService.deleteList(list.id!);
        print('DEBUG: Custom list deleted successfully');
        
        // Reload lists
        await _loadLists();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف القائمة: ${list.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error deleting custom list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف القائمة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
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
              // Header
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
                        'إدارة الأحداث والتواريخ',
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // My Lists section
                      Text(
                        'قوائمي',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // List items
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      else if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(screenHeight * 0.015),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: screenHeight * 0.08,
                                color: Colors.red[400],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'خطأ في تحميل القوائم',
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
                                  _loadLists();
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
                      else if (allLists.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(screenHeight * 0.015),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: screenHeight * 0.08,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'لا توجد قوائم متاحة',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'سيتم إنشاء القوائم الافتراضية تلقائياً',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.016,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...allLists.map((list) => _buildListItem(list, screenHeight, screenWidth)).toList(),

                      SizedBox(height: screenHeight * 0.04),

                      // Create New List section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنشاء قائمة جديدة',
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            Text(
                              allLists.any((list) => !list.isPredefined) 
                                  ? 'تم إضافة القائمة المخصصة بالفعل\nيمكنك حذفها لإنشاء قائمة جديدة'
                                  : 'يمكنك إضافة قائمة واحدة جديدة',
                              style: TextStyle(
                                fontSize: screenHeight * 0.018,
                                color: allLists.any((list) => !list.isPredefined) 
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: screenHeight * 0.06,
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(screenHeight * 0.01),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextField(
                                      controller: listNameController,
                                      enabled: !allLists.any((list) => !list.isPredefined),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.018,
                                        color: allLists.any((list) => !list.isPredefined) 
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                      ),
                                      decoration: InputDecoration(
                                        hintText: allLists.any((list) => !list.isPredefined) 
                                            ? 'تم إضافة القائمة المخصصة'
                                            : 'اسم القائمة',
                                        hintStyle: TextStyle(
                                          fontSize: screenHeight * 0.018,
                                          color: Colors.grey[500],
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Container(
                                  height: screenHeight * 0.06,
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                                  decoration: BoxDecoration(
                                    color: allLists.any((list) => !list.isPredefined) 
                                        ? Colors.grey[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                                  ),
                                  child: TextButton(
                                    onPressed: allLists.any((list) => !list.isPredefined) 
                                        ? null 
                                        : () async {
                                            if (listNameController.text.isNotEmpty) {
                                              await _createNewList(listNameController.text);
                                              listNameController.clear();
                                            }
                                          },
                                    child: Text(
                                      'حفظ',
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.018,
                                        fontWeight: FontWeight.w500,
                                        color: allLists.any((list) => !list.isPredefined) 
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildListItem(EventList list, double screenHeight, double screenWidth) {
    bool isSelected = selectedLists.contains(list.id.toString());
    
    return GestureDetector(
      onTap: () {
        // Navigate to EventsPage when tapping on the list
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsPage(
              listTitle: list.name,
              listId: list.id!,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenHeight * 0.015),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
             // Checkbox
             GestureDetector(
               onTap: () async {
                 setState(() {
                   if (isSelected) {
                     // Only allow deselection if there's more than one list selected
                     if (selectedLists.length > 1) {
                       selectedLists.remove(list.id.toString());
                     }
                   } else {
                     selectedLists.add(list.id.toString());
                   }
                 });
                 
                 // Update database
                 final updatedList = list.copyWith(isEnabled: !isSelected);
                 await DatabaseService.updateList(updatedList);
                 
                 // Save selected lists to SharedPreferences
                 await DatabaseService.saveSelectedLists(selectedLists);
               },
              child: Container(
                width: screenHeight * 0.025,
                height: screenHeight * 0.025,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[400]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: screenHeight * 0.018,
                      )
                    : null,
              ),
            ),
            
            SizedBox(width: screenWidth * 0.03),
            
            // List content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  FutureBuilder<int>(
                    future: DatabaseService.getEventCount(list.id!),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Text(
                        '$count أحداث',
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete button (only for custom lists)
                if (!list.isPredefined)
                  GestureDetector(
                    onTap: () => _deleteCustomList(list),
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.008),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.red[600],
                        size: screenHeight * 0.02,
                      ),
                    ),
                  ),
                SizedBox(width: screenWidth * 0.02),
                // Navigation arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: screenHeight * 0.02,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
